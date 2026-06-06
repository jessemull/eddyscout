---
name: form-creation
description: >-
  Build user-facing forms with validation, submission, and feedback states.
  Use when creating login, registration, profile, settings, or any input
  submission flow.
---

# Form Creation

Read the following before building any user-facing form:

- `CONTEXT.md`
- `AGENTS.md`
- `docs/ARCHITECTURE.md`
- `docs/STATE_MANAGEMENT.md`
- `docs/TESTING.md`
- `docs/SECURITY.md`
- `docs/ACCESSIBILITY.md`
- `docs/UI.md`
- `docs/PERFORMANCE.md`
- `docs/CODEGEN.md`

Companion skills:
- `accessibility-review` — deep a11y audit for form interactions
- `riverpod-usage` — provider patterns for form state
- `testing` — widget test conventions for form flows
- `security-review` — input sanitization and PII handling

Forms are one of the highest-risk UI constructs because they combine:
- user input
- validation logic
- async submission
- state management
- error handling
- security concerns
- accessibility requirements

Forms must be:
- predictable
- validated
- resilient
- accessible
- testable
- secure
- and fully state-driven

---

# When to Use

Use this skill when:

- creating login forms
- signup/registration forms
- checkout flows
- profile editing forms
- search/filter forms with validation
- multi-step forms (wizards)
- settings forms
- any user input submission flow

---

# Core Form Principles

## State Must Be Externalized

Form state must NOT live in widgets.

All form state must be handled by:
- Riverpod notifiers
- state classes
- domain models (where applicable)

Widgets are only:
- rendering state
- forwarding input events
- displaying validation feedback

---

## Validation Must Be Deterministic

Validation must be:
- synchronous where possible
- pure (no side effects)
- reusable
- testable outside UI

Avoid:
- inline business logic in widgets
- hidden validation side effects
- async validation in build methods

---

## Submission Is a State Machine

Form submission must be modeled explicitly:

```text
idle → validating → submitting → success | error
```

Never treat submission as a simple function call without state tracking.

---

# 1. Form Architecture Design

Before implementation:

- [ ] define input fields
- [ ] define validation rules
- [ ] define submission flow
- [ ] define error states
- [ ] define success behavior
- [ ] define navigation behavior after success
- [ ] define loading UX
- [ ] define accessibility requirements
- [ ] define security considerations

---

# 2. Widget Construction

## Form Structure

- [ ] Use `Form` widget with `GlobalKey<FormState>`
- [ ] Group fields logically
- [ ] Avoid deeply nested widget trees
- [ ] Extract reusable input widgets

## Input Fields

For each field:

- [ ] correct `TextInputType`
- [ ] correct `TextInputAction`
- [ ] proper autofill hints where applicable
- [ ] proper keyboard behavior
- [ ] correct capitalization settings

## Validation UI

- [ ] validator returns `null` for valid input
- [ ] error messages are user-friendly
- [ ] error messages are consistent with domain rules
- [ ] validation feedback is immediate where appropriate

---

# 3. State Management (Riverpod)

## Form Notifier

- [ ] create `@riverpod` notifier or equivalent
- [ ] maintain explicit form state model
- [ ] expose `AsyncValue` or state machine for submission

## State Responsibilities

Notifier must handle:
- validation orchestration (if centralized)
- submission logic
- API interaction
- error normalization
- success handling

Widget must NOT:
- call APIs directly
- contain business logic
- manage submission state manually

---

## State Model Example

Form state should be explicit:

```text
FormState:
- field values
- validation errors
- submission status
- submission error message
```

---

# 4. Submission Flow

## Pre-Submission

- [ ] validate form via `formKey.currentState!.validate()`
- [ ] ensure all fields are valid
- [ ] normalize input if needed (trim, format, etc.)

## Submission

- [ ] trigger notifier submit method
- [ ] set state to loading
- [ ] perform async operation
- [ ] handle success/failure explicitly

## Post-Submission

- [ ] reset form if appropriate
- [ ] navigate on success if required
- [ ] show confirmation UI
- [ ] handle retry behavior

---

# 5. Async State Handling

## Loading State

- [ ] disable submit button
- [ ] show loading indicator
- [ ] prevent duplicate submissions

## Error State

- [ ] show inline errors where appropriate
- [ ] show global error (SnackBar/dialog) when needed
- [ ] preserve form input on error

## Success State

- [ ] show confirmation
- [ ] navigate if required
- [ ] reset form only if appropriate

---

# 6. UX & UI Behavior

## Input UX

- [ ] correct autofill hints used
- [ ] keyboard optimized per field
- [ ] focus moves logically between fields
- [ ] submit triggered from keyboard where appropriate

## Feedback UX

- [ ] immediate validation feedback
- [ ] clear error messages
- [ ] no ambiguous error states
- [ ] consistent success feedback

---

# 7. Accessibility Requirements

## Semantics

- [ ] every field has label
- [ ] error messages announced to screen readers
- [ ] required fields indicated properly

## Interaction

- [ ] touch targets ≥ 48×48 dp
- [ ] logical tab order
- [ ] focus moves predictably
- [ ] focus shifts on error or submission feedback

## Visual Accessibility

- [ ] text scaling supported (no fixed-height text containers)
- [ ] contrast meets WCAG AA
- [ ] error states distinguishable without color alone
- [ ] disabled states visually clear

---

# 8. Security Requirements

## Input Sanitization

- [ ] user input validated before submission
- [ ] length limits enforced on all text fields
- [ ] HTML/script content stripped or escaped
- [ ] unsafe assumptions avoided

## Sensitive Data

- [ ] no PII logged
- [ ] password fields use `obscureText: true`
- [ ] sensitive data stored via platform-secure mechanisms only
- [ ] credentials never cached in plain-text state

## Submission Safety

- [ ] HTTPS enforced for all form submissions
- [ ] no secrets hardcoded in form logic
- [ ] auth tokens handled by interceptors, not form code

---

# 9. Testing Requirements

## Widget Tests

- [ ] form renders correctly in all states (idle, loading, error, success)
- [ ] validation errors display correctly
- [ ] submission flow tested end-to-end with mocked providers
- [ ] keyboard interactions tested where applicable

## State Tests

- [ ] notifier validation logic tested independently
- [ ] submission success/failure paths tested
- [ ] edge cases tested (empty input, boundary values, special characters)

## Accessibility Tests

- [ ] semantic labels verified in widget tests
- [ ] focus order tested where critical
- [ ] error announcements verified where applicable

## Test Quality

- [ ] tests deterministic
- [ ] no real network calls
- [ ] mock external I/O with `mocktail`

---

# 10. Common Anti-Patterns

## MUST NOT

- [ ] put validation or submission logic in widgets
- [ ] call APIs directly from form widgets
- [ ] use `setState` for form submission state
- [ ] ignore loading/error states
- [ ] hardcode error messages (use localization)
- [ ] store passwords or PII in plain-text state
- [ ] allow duplicate submissions

## SHOULD AVOID

- [ ] deeply nested form widget trees
- [ ] inline validation logic in build methods
- [ ] ambiguous error messages
- [ ] placeholder-only labels (always provide visible or semantic labels)
- [ ] fixed-height text containers in form fields

---

# 11. Validation Checklist

Before committing:

- [ ] form renders correctly
- [ ] validation works
- [ ] submission flow works
- [ ] loading/error/success states handled
- [ ] accessibility verified
- [ ] security reviewed
- [ ] tests pass
- [ ] push validation passes (`git push` hook; see `CONTEXT.md`)

Run while iterating:

```bash
make analyze
melos exec --scope=<package> -- "flutter test"
```

---

# 12. Output Expectations

When building a form, provide:

## Form Summary
- fields and validation rules
- submission flow description
- state management approach

## Accessibility Notes
- semantic labels provided
- focus order verified
- screen reader behavior confirmed

## Security Notes
- input sanitization approach
- sensitive data handling
- submission security

## Validation Results
- tests added
- states covered
- preflight status