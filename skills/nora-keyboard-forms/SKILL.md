---
name: nora-keyboard-forms
description: Build and review keyboard-aware SwiftUI forms for Nora. Use whenever a screen, sheet, dialog, or component contains TextField, SecureField, TextEditor, searchable input, or another editable control together with an action button, submit control, or bottom CTA.
---

# Nora keyboard forms

Ensure every form remains usable while the software keyboard is visible.

## Required behavior

- Track active input with `@FocusState` and provide correct submit transitions between fields.
- Keep the primary action visible and tappable above the keyboard. Do not assume `safeAreaInset(edge: .bottom)` works correctly when nested with `ZStack`, `ScrollView`, keyboard toolbars, or full-bleed backgrounds; verify it on the simulator.
- Prefer placing the form and CTA in a `ScrollViewReader`, then scroll the CTA into view after the keyboard finishes its layout transition. Never rely on the user discovering a hidden button by scrolling.
- Preserve at least `TouchTarget.minimum` clearance and never position actionable content behind the keyboard, prediction bar, or password AutoFill bar.
- Support interactive keyboard dismissal on scroll and provide an explicit Done action when the keyboard has no natural dismissal path.
- Submit from the final field only when validation allows it. Dismiss focus before starting the async action.
- Keep error messages reachable after submission and scroll or focus the first invalid field when appropriate.
- Do not apply `ignoresSafeArea(.keyboard)` to foreground form content or primary actions.

## Implementation pattern

1. Add a focus enum and `@FocusState` property.
2. Put overflow-prone content in a `ScrollView` with `.scrollDismissesKeyboard(.interactively)`.
3. Give the CTA a stable ID and call `proxy.scrollTo(..., anchor: .bottom)` after the keyboard transition when focus becomes active.
4. Reduce decorative top spacing while a field is focused when compact height needs more room.
5. Use `.safeAreaInset(edge: .bottom)` only after confirming the CTA remains visible with the keyboard toolbar and AutoFill bar enabled.
6. Add a keyboard toolbar Done button when necessary.
7. Test keyboard-hidden, keyboard-visible, AutoFill-bar, compact-height, and large Dynamic Type states.

## Completion checklist

1. Focus every editable field and confirm neither the field nor its CTA is obscured.
2. Confirm Next, Go, Return, and Done produce intentional focus or submit behavior.
3. Confirm scrolling can dismiss the keyboard without losing entered values.
4. Build the relevant Xcode scheme.
