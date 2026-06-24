"""Load shared confluence audit definitions from confluence_audit.json."""

from __future__ import annotations

import json
from pathlib import Path
from typing import Any

_AUDIT_PATH = Path(__file__).resolve().parent / "confluence_audit.json"


def confluence_audit_path() -> Path:
    return _AUDIT_PATH


def load_confluence_audit_pairs() -> list[dict[str, Any]]:
    """Return raw pair rows from the shared audit JSON."""
    data = json.loads(_AUDIT_PATH.read_text(encoding="utf-8"))
    pairs = data.get("pairs")
    if not isinstance(pairs, list):
        raise ValueError(f"Expected 'pairs' list in {_AUDIT_PATH}")
    return pairs


def load_confluence_audit_compare_entries() -> list[dict[str, Any]]:
    """Format pair rows for NHD compare confluence snap tables."""
    entries: list[dict[str, Any]] = []
    for pair in load_confluence_audit_pairs():
        entries.append(
            {
                "id": pair["id"],
                "required": bool(pair.get("required", False)),
                "informational": bool(pair.get("informational", False)),
                "upstream_end": pair["upstream_anchor"],
                "downstream_start": pair["downstream_anchor"],
            }
        )
    return entries
