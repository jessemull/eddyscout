# Form Creation

> Read `CONTEXT.md` and `AGENTS.md` before using this skill.

## When to Use

Use when building a user-facing form with validation, submission, and feedback states.

## References

- `docs/ARCHITECTURE.md` — layer separation rules
- `docs/TESTING.md` — widget test conventions

## Checklist

### 1. Create the Form Widget

- [ ] Use a `Form` widget with a `GlobalKey<FormState>`
- [ ] Add `TextFormField` widgets with appropriate `TextInputType` and `TextInputAction`
- [ ] Add `validator:` callbacks that return `null` on success, error string on failure
- [ ] Use `AutovalidateMode.onUserInteraction` for immediate feedback

### 2. Manage Form State with Riverpod

- [ ] Create a notifier (e.g., `@riverpod` class) to hold form state
- [ ] Expose an `AsyncValue` for submission status
- [ ] Keep all validation and submission logic in the notifier — never in the widget

### 3. Handle Submission

- [ ] Call `formKey.currentState!.validate()` before submitting
- [ ] Invoke the notifier's submit method
- [ ] Use `AsyncValue` to track loading → success / error

### 4. Show Loading / Error / Success States

- [ ] Disable the submit button and show a `CircularProgressIndicator` during loading
- [ ] Show error messages via `SnackBar` or inline error text
- [ ] Navigate or show confirmation on success

### 5. Accessibility

- [ ] Add `labelText` or `Semantics` label to every input
- [ ] Ensure touch targets are at least 48×48 dp
- [ ] Verify focus order follows visual order
- [ ] Test with `TalkBack` / `VoiceOver` if possible

### 6. Test

- [ ] Widget test: renders all fields, validates input, shows error states
- [ ] Widget test: successful submission navigates or shows confirmation
- [ ] Mock the notifier/provider with `ProviderScope.overrides`
- [ ] Run `make preflight`
