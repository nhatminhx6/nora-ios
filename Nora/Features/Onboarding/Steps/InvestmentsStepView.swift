import SwiftUI

struct InvestmentsStepView: View {
    @Bindable var store: OnboardingStore
    let onNext: () -> Void
    let onBack: () -> Void
    let onSkip: () -> Void

    var body: some View {
        OnboardingScaffold(
            progress: progressValue,
            title: "Nói rõ hơn một chút",
            subtitle: "Thông tin bổ sung giúp Nora lọc chính xác hơn. Mỗi mục cách nhau bằng dấu phẩy.",
            canGoBack: true,
            onBack: onBack,
            primaryTitle: "Tiếp tục",
            isPrimaryEnabled: true,
            onPrimary: onNext,
            onSkip: onSkip
        ) {
            LazyVStack(alignment: .leading, spacing: Spacing.lg) {
                ForEach(store.selectedCatalogItems) { item in
                    VStack(alignment: .leading, spacing: Spacing.sm) {
                        Label(item.name, systemImage: item.symbol)
                            .font(.noraCardTitle)
                            .foregroundStyle(Color.noraTextPrimary)

                        Text(item.refinementLabel)
                            .font(.noraSupporting)
                            .foregroundStyle(Color.noraTextSecondary)

                        TextField(
                            item.refinementPlaceholder,
                            text: Binding(
                                get: { store.refinementText[item.key] ?? "" },
                                set: { store.refinementText[item.key] = $0 }
                            ),
                            axis: .vertical
                        )
                        .textFieldStyle(.plain)
                        .font(.noraBody)
                        .lineLimit(1...3)
                        .noraInputFieldBackground()
                    }
                    .noraSurfaceCard()
                }
            }
        }
    }

    private var progressValue: Double {
        Double(OnboardingStep.investments.progressIndex) / Double(OnboardingStep.allCases.count - 1)
    }
}

#Preview {
    InvestmentsStepView(store: OnboardingStore(environment: .preview(), onComplete: {}), onNext: {}, onBack: {}, onSkip: {})
}
