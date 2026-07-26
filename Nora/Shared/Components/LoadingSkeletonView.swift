import SwiftUI

/// A single skeleton line with a very subtle shimmer, sized to stand in for
/// real content rather than a spinner.
struct SkeletonLine: View {
    var width: CGFloat? = nil
    var height: CGFloat = 14

    @State private var isAnimating = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        RoundedRectangle(cornerRadius: Radius.sm / 2, style: .continuous)
            .fill(Color.noraSurface)
            .frame(width: width, height: height)
            .opacity(isAnimating ? 0.6 : 1)
            .onAppear {
                guard !reduceMotion else { return }
                withAnimation(.easeInOut(duration: 0.9).repeatForever(autoreverses: true)) {
                    isAnimating = true
                }
            }
    }
}

/// Placeholder for an `InsightRowView` while a brief is loading, matching
/// its real footprint so content doesn't jump into place.
struct InsightRowSkeleton: View {
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            SkeletonLine(width: 90, height: 12)
            SkeletonLine(width: 220, height: 16)
            SkeletonLine(height: 14)
            SkeletonLine(width: 160, height: 12)
        }
        .padding(.vertical, Spacing.sm)
    }
}

struct TodaySkeletonView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xl) {
            VStack(alignment: .leading, spacing: Spacing.sm) {
                SkeletonLine(width: 140, height: 13)
                SkeletonLine(width: 240, height: 22)
            }

            VStack(alignment: .leading, spacing: Spacing.base) {
                SkeletonLine(width: 130, height: 18)
                InsightRowSkeleton()
                Divider().overlay(Color.noraDivider)
                InsightRowSkeleton()
            }
        }
        .noraScreenPadding()
        .accessibilityHidden(true)
    }
}

#Preview {
    TodaySkeletonView()
}
