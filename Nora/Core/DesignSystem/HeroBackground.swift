import SwiftUI

/// The shared photographic environment for every Nora screen. Onboarding and
/// the main app intentionally use the same city, fog, warm flare, and dark
/// lower gradient so completing onboarding never feels like entering a
/// different product.
struct NoraHeroBackground: View {
    var intensity: Double = 1

    var body: some View {
        GeometryReader { proxy in
            Image("WelcomeCity")
                .resizable()
                .scaledToFill()
                .frame(width: proxy.size.width, height: proxy.size.height)
                .clipped()
                .overlay {
                    LinearGradient(
                        stops: [
                            .init(color: mist.opacity(0.12 * intensity), location: 0),
                            .init(color: deepTeal.opacity(0.28 * intensity), location: 0.28),
                            .init(color: deepNavy.opacity(0.68 * intensity), location: 0.66),
                            .init(color: deepNavy.opacity(0.94), location: 1),
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                }
                .overlay {
                    LinearGradient(
                        colors: [
                            Color(red: 0.02, green: 0.45, blue: 0.50).opacity(0.24 * intensity),
                            .clear,
                            Color.orange.opacity(0.10 * intensity),
                        ],
                        startPoint: .topLeading,
                        endPoint: .topTrailing
                    )
                }
        }
        .ignoresSafeArea()
        .accessibilityHidden(true)
    }

    private let mist = Color(red: 0.66, green: 0.77, blue: 0.79)
    private let deepTeal = Color(red: 0.02, green: 0.19, blue: 0.23)
    private let deepNavy = Color(red: 0.01, green: 0.04, blue: 0.07)
}

#Preview {
    ZStack {
        NoraHeroBackground()
        Text("Nora")
            .font(.system(size: 52, weight: .bold))
            .foregroundStyle(.white)
    }
}
