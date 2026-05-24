# Navigation Change

> Read `CONTEXT.md` and `AGENTS.md` before using this skill.

## When to Use

Use when adding, modifying, or removing routes and navigation flows.

## References

- `docs/NAVIGATION.md` — routing conventions, guard patterns, deep link config

## Checklist

### 1. Add a Typed Route

- [ ] Create a `@TypedGoRoute` annotation on the route data class in the feature
- [ ] Define path parameters and query parameters as class fields
- [ ] Run `make gen` to generate the route extension

### 2. Register in Router Config

- [ ] Add the route to the `GoRouter` configuration
- [ ] Nest child routes under parent routes where appropriate
- [ ] Verify the route path is unique and follows naming conventions

### 3. Add Auth Guards

- [ ] Add `redirect` logic if the route requires authentication
- [ ] Check auth state via Riverpod provider in the redirect callback
- [ ] Redirect unauthenticated users to the login route
- [ ] Handle expired sessions gracefully

### 4. Test Deep Links

- [ ] Verify the route resolves correctly from a cold start
- [ ] Test with `flutter run --route='/your/path'`
- [ ] Validate path parameters and query parameters are parsed
- [ ] Test malformed deep link URLs are handled (redirect to fallback)

### 5. Verify Back-Stack Behavior

- [ ] System back button navigates to the expected parent
- [ ] `context.pop()` returns to the previous route
- [ ] `context.go()` vs. `context.push()` used correctly:
  - `go()` — replaces the stack (top-level navigation)
  - `push()` — adds to the stack (drill-down navigation)
- [ ] Nested navigation shells maintain their own back-stack

### 6. Validate and Commit

- [ ] Run `make gen` if typed routes were added/changed
- [ ] Run `make preflight`
- [ ] Commit with `feat(<scope>): add <route> route` or `fix(<scope>): ...`
