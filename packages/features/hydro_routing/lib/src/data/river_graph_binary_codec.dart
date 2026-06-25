import 'dart:convert';
import 'dart:typed_data';

import 'package:eddyscout_hydro_routing/src/data/river_graph.dart';

int _compareGraphEdges(GraphEdge a, GraphEdge b) {
  final toCmp = a.to.compareTo(b.to);
  if (toCmp != 0) {
    return toCmp;
  }
  final wCmp = a.w - b.w;
  if (wCmp.abs() > 0.01) {
    return wCmp.compareTo(0);
  }
  final riverCmp = (a.riverSystem ?? '').compareTo(b.riverSystem ?? '');
  if (riverCmp != 0) {
    return riverCmp;
  }
  return (a.oneWay ? 1 : 0).compareTo(b.oneWay ? 1 : 0);
}

List<List<GraphEdge>> _sortedAdjacency(List<List<GraphEdge>> adj) {
  return [
    for (final edges in adj)
      (List<GraphEdge>.from(edges)..sort(_compareGraphEdges)),
  ];
}

/// Current binary graph format version.
const kRiverGraphBinaryFormatVersion = 1;

/// Magic bytes identifying EddyScout hydro graph binaries.
const kRiverGraphBinaryMagic = 'EDHY';

/// Metadata stored alongside serialized graph bytes.
class RiverGraphBinaryMetadata {
  /// Creates graph binary metadata.
  const RiverGraphBinaryMetadata({
    this.mergeVertexMeters = 12,
    this.generatedAtIso,
    this.sourceHash,
  });

  /// Vertex merge threshold used when building the graph.
  final double mergeVertexMeters;

  /// UTC ISO-8601 timestamp when the binary was generated.
  final String? generatedAtIso;

  /// Optional hash of source GeoJSON inputs for staleness checks.
  final String? sourceHash;
}

/// Encodes [graph] to compact little-endian binary.
Uint8List encodeRiverLineGraph(
  RiverLineGraph graph, {
  RiverGraphBinaryMetadata metadata = const RiverGraphBinaryMetadata(),
}) {
  final payload = graph.binaryPayloadForCodec;
  final strings = <String>[];
  final stringIndex = <String, int>{};

  int indexOf(String? value) {
    if (value == null || value.isEmpty) {
      return -1;
    }
    final existing = stringIndex[value];
    if (existing != null) {
      return existing;
    }
    final index = strings.length;
    strings.add(value);
    stringIndex[value] = index;
    return index;
  }

  final reachIndices = payload.vertexReachId.map(indexOf).toList();
  final edgeRiverIndices = <int>[];
  final edgeOneWay = <int>[];
  final edgeTo = <int>[];
  final edgeWeight = <double>[];
  final rowOffsets = <int>[0];

  for (final edges in payload.adj) {
    final sorted = List<GraphEdge>.from(edges)..sort(_compareGraphEdges);
    for (final e in sorted) {
      edgeTo.add(e.to);
      edgeWeight.add(e.w);
      edgeRiverIndices.add(indexOf(e.riverSystem));
      edgeOneWay.add(e.oneWay ? 1 : 0);
    }
    rowOffsets.add(edgeTo.length);
  }

  final metadataBytes = utf8.encode(
    jsonEncode({
      'mergeVertexMeters': metadata.mergeVertexMeters,
      if (metadata.generatedAtIso != null)
        'generatedAt': metadata.generatedAtIso,
      if (metadata.sourceHash != null) 'sourceHash': metadata.sourceHash,
    }),
  );

  final totalEdges = edgeTo.length;
  final vertexCount = payload.lat.length;
  final buffer = BytesBuilder(copy: false);

  void writeUint32(int value) {
    final bytes = ByteData(4)..setUint32(0, value, Endian.little);
    buffer.add(bytes.buffer.asUint8List());
  }

  void writeInt32(int value) {
    final bytes = ByteData(4)..setInt32(0, value, Endian.little);
    buffer.add(bytes.buffer.asUint8List());
  }

  void writeFloat64(double value) {
    final bytes = ByteData(8)..setFloat64(0, value, Endian.little);
    buffer.add(bytes.buffer.asUint8List());
  }

  void writeUint16(int value) {
    final bytes = ByteData(2)..setUint16(0, value, Endian.little);
    buffer.add(bytes.buffer.asUint8List());
  }

  void writeUint8(int value) {
    buffer.addByte(value);
  }

  buffer.add(utf8.encode(kRiverGraphBinaryMagic));
  writeUint32(kRiverGraphBinaryFormatVersion);
  writeUint32(vertexCount);
  writeUint32(totalEdges);
  writeUint32(strings.length);
  writeUint32(metadataBytes.length);
  buffer.add(metadataBytes);

  payload.lat.forEach(writeFloat64);
  payload.lon.forEach(writeFloat64);
  payload.componentId.forEach(writeUint32);
  reachIndices.forEach(writeInt32);

  rowOffsets.forEach(writeUint32);
  for (var i = 0; i < edgeTo.length; i++) {
    writeUint32(edgeTo[i]);
    writeFloat64(edgeWeight[i]);
    writeUint16(edgeRiverIndices[i] < 0 ? 0 : edgeRiverIndices[i] + 1);
    writeUint8(edgeOneWay[i]);
  }

  for (final s in strings) {
    final encoded = utf8.encode(s);
    writeUint32(encoded.length);
    buffer.add(encoded);
  }

  return buffer.toBytes();
}

/// Decodes a graph from [bytes].
RiverLineGraph decodeRiverLineGraph(Uint8List bytes) {
  var offset = 0;

  int readUint32() {
    final value = ByteData.sublistView(bytes, offset, offset + 4).getUint32(
      0,
      Endian.little,
    );
    offset += 4;
    return value;
  }

  int readInt32() {
    final value = ByteData.sublistView(bytes, offset, offset + 4).getInt32(
      0,
      Endian.little,
    );
    offset += 4;
    return value;
  }

  double readFloat64() {
    final value = ByteData.sublistView(bytes, offset, offset + 8).getFloat64(
      0,
      Endian.little,
    );
    offset += 8;
    return value;
  }

  int readUint16() {
    final value = ByteData.sublistView(bytes, offset, offset + 2).getUint16(
      0,
      Endian.little,
    );
    offset += 2;
    return value;
  }

  int readUint8() {
    final value = bytes[offset];
    offset += 1;
    return value;
  }

  final magic = utf8.decode(bytes.sublist(offset, offset + 4));
  offset += 4;
  if (magic != kRiverGraphBinaryMagic) {
    throw FormatException('Invalid hydro graph magic: $magic');
  }

  final version = readUint32();
  if (version != kRiverGraphBinaryFormatVersion) {
    throw FormatException('Unsupported hydro graph version: $version');
  }

  final vertexCount = readUint32();
  final totalEdges = readUint32();
  final stringCount = readUint32();
  final metadataLength = readUint32();
  if (offset + metadataLength > bytes.length) {
    throw const FormatException('Truncated hydro graph metadata');
  }
  offset += metadataLength;

  final lat = List<double>.generate(vertexCount, (_) => readFloat64());
  final lon = List<double>.generate(vertexCount, (_) => readFloat64());
  final componentId = List<int>.generate(vertexCount, (_) => readUint32());
  final reachIndices = List<int>.generate(vertexCount, (_) => readInt32());

  final rowOffsets = List<int>.generate(vertexCount + 1, (_) => readUint32());
  if (rowOffsets.last != totalEdges) {
    throw FormatException(
      'Edge count mismatch: header=$totalEdges offsets=${rowOffsets.last}',
    );
  }

  final edgeTo = List<int>.filled(totalEdges, 0);
  final edgeWeight = List<double>.filled(totalEdges, 0);
  final edgeRiverIndex = List<int>.filled(totalEdges, 0);
  final edgeOneWay = List<bool>.filled(totalEdges, false);

  for (var i = 0; i < totalEdges; i++) {
    edgeTo[i] = readUint32();
    edgeWeight[i] = readFloat64();
    edgeRiverIndex[i] = readUint16();
    edgeOneWay[i] = readUint8() != 0;
  }

  final strings = <String>[];
  for (var i = 0; i < stringCount; i++) {
    final length = readUint32();
    if (offset + length > bytes.length) {
      throw const FormatException('Truncated hydro graph string table');
    }
    strings.add(utf8.decode(bytes.sublist(offset, offset + length)));
    offset += length;
  }

  String? stringAt(int index) {
    if (index < 0) {
      return null;
    }
    return strings[index];
  }

  final vertexReachId = reachIndices.map(stringAt).toList(growable: false);

  final adj = List<List<GraphEdge>>.generate(vertexCount, (_) => []);
  for (var u = 0; u < vertexCount; u++) {
    for (var e = rowOffsets[u]; e < rowOffsets[u + 1]; e++) {
      final riverIdx = edgeRiverIndex[e];
      adj[u].add(
        (
          to: edgeTo[e],
          w: edgeWeight[e],
          riverSystem: riverIdx == 0 ? null : strings[riverIdx - 1],
          oneWay: edgeOneWay[e],
        ),
      );
    }
  }

  return RiverLineGraph.fromBinaryPayload(
    lat: lat,
    lon: lon,
    adj: adj,
    componentId: componentId,
    vertexReachId: vertexReachId,
  );
}

/// Whether two graphs have identical topology and vertex data.
bool riverGraphsEqual(RiverLineGraph a, RiverLineGraph b) {
  final pa = a.binaryPayloadForCodec;
  final pb = b.binaryPayloadForCodec;
  if (pa.lat.length != pb.lat.length) {
    return false;
  }
  for (var i = 0; i < pa.lat.length; i++) {
    if (!_coordsNearlyEqual(pa.lat[i], pb.lat[i]) ||
        !_coordsNearlyEqual(pa.lon[i], pb.lon[i]) ||
        pa.componentId[i] != pb.componentId[i] ||
        pa.vertexReachId[i] != pb.vertexReachId[i]) {
      return false;
    }
  }
  final adjA = _sortedAdjacency(pa.adj);
  final adjB = _sortedAdjacency(pb.adj);
  if (adjA.length != adjB.length) {
    return false;
  }
  for (var u = 0; u < adjA.length; u++) {
    final edgesA = adjA[u];
    final edgesB = adjB[u];
    if (edgesA.length != edgesB.length) {
      return false;
    }
    for (var e = 0; e < edgesA.length; e++) {
      if (_compareGraphEdges(edgesA[e], edgesB[e]) != 0) {
        return false;
      }
    }
  }
  return true;
}

bool _coordsNearlyEqual(double a, double b) => (a - b).abs() < 1e-7;

/// Payload snapshot for binary encoding.
class RiverGraphBinaryPayload {
  /// Creates a binary payload snapshot.
  const RiverGraphBinaryPayload({
    required this.lat,
    required this.lon,
    required this.adj,
    required this.componentId,
    required this.vertexReachId,
  });

  /// Vertex latitudes in degrees.
  final List<double> lat;

  /// Vertex longitudes in degrees.
  final List<double> lon;

  /// Adjacency lists.
  final List<List<GraphEdge>> adj;

  /// Connected-component labels per vertex.
  final List<int> componentId;

  /// Reach id per vertex when known.
  final List<String?> vertexReachId;
}
