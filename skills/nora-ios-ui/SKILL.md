---
name: nora-ios-ui
description: Build and review Nora iOS SwiftUI screens using the project's design tokens, safe-area spacing, native controls, and accessibility conventions. Use whenever creating, editing, or reviewing a SwiftUI view in the Nora iOS repository, especially full-screen layouts, forms, onboarding, authentication, navigation, sheets, and reusable UI components.
---

# Nora iOS UI

Build polished Nora screens that remain readable, comfortably inset, and consistent across iPhone sizes.

## Layout requirements

- Keep full-bleed backgrounds and decorative media edge-to-edge when intended.
- Inset all readable or interactive foreground content from the safe-area edges. Never place titles, body text, fields, buttons, cards, lists, or controls flush against a screen edge.
- Use at least `Spacing.xl` (24 pt) horizontal content padding on compact iPhone screens. Prefer `Spacing.xxl` (32 pt) for focused forms and authentication screens.
- Apply padding to the shared foreground container so sibling elements align to one vertical grid. Avoid scattered per-element edge padding.
- Respect safe areas for foreground content. Only backgrounds may use `ignoresSafeArea()` by default.
- Constrain wide layouts with a sensible `maxWidth`, then center the container.
- Check small-screen and large Dynamic Type layouts before completion. Use scrolling when vertical content can overflow.

## Visual and interaction requirements

- Reuse `Color.nora*`, `Font.nora*`, `Spacing`, `Radius`, and existing button styles instead of introducing unrelated constants.
- Use SF Symbols by name for interface icons.
- Keep touch targets at least `TouchTarget.minimum`.
- Ensure text and placeholder contrast remains legible over photographic backgrounds.
- Provide visible focus, loading, disabled, and error states for forms.
- Avoid obsolete Nora logo assets unless the user explicitly asks to restore them.

## Completion checklist

1. Verify foreground content has a clear 24–32 pt horizontal inset.
2. Verify background-only elements are the only views extending under unsafe edges.
3. Build the relevant Xcode scheme with strict concurrency enabled.
4. Inspect the final screen at a compact iPhone size when visual tooling is available.
