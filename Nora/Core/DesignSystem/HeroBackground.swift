import SwiftUI

/// A dark, moody, glossy backdrop built from an iOS 18 `MeshGradient`:
/// deep navy base with glowing teal blooms and a warm daylight highlight —
/// the "sun through fog at dusk" feel. Designed to sit under light (white)
/// text with frosted-glass cards glowing on top. Always renders dark, so the
/// hero screens read the same in Light and Dark Mode.
struct NoraHeroBackground: View {
    /// Kept for call-site compatibility; the moody hero is always full-bleed.
    var intensity: Double = 1

    var body: some View {
        ZStack {
            base

            MeshGradient(
                width: 3,
                height: 3,
                points: [
                    [0.0, 0.0], [0.5, 0.0], [1.0, 0.0],
                    [0.0, 0.5], [0.5, 0.5], [1.0, 0.5],
                    [0.0, 1.0], [0.5, 1.0], [1.0, 1.0],
                ],
                colors: [
                    tealGlow, teal, warmGlow,
                    navy, tealDeep, blueDeep,
                    base, base, base,
                ]
            )
        }
        .ignoresSafeArea()
    }

    // Fixed moody palette — the hero is always dark regardless of theme.
    private let base = Color(red: 0.04, green: 0.07, blue: 0.10)
    private var tealGlow: Color { Color(red: 0.10, green: 0.55, blue: 0.58) }
    private var teal: Color { Color(red: 0.06, green: 0.40, blue: 0.46) }
    private var warmGlow: Color { Color(red: 0.62, green: 0.44, blue: 0.26) }
    private var navy: Color { Color(red: 0.05, green: 0.12, blue: 0.20) }
    private var tealDeep: Color { Color(red: 0.04, green: 0.30, blue: 0.36) }
    private var blueDeep: Color { Color(red: 0.05, green: 0.10, blue: 0.22) }
}

#Preview {
    ZStack {
        NoraHeroBackground()
        Text("Welcome")
            .font(.system(size: 52, weight: .bold))
            .foregroundStyle(.white)
    }
}
