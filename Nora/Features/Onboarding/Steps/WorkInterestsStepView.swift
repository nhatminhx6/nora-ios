import SwiftUI

struct WorkInterestsStepView: View {
    @Bindable var store: OnboardingStore
    let onNext: () -> Void
    let onSkip: () -> Void

    var body: some View {
        OnboardingScaffold(
            progress: progressValue,
            title: "Anh muốn Nora theo dõi điều gì?",
            subtitle: "Chọn ít nhất một chủ đề. Nora sẽ chuẩn bị nguồn dữ liệu phù hợp cho từng chủ đề.",
            canGoBack: false,
            onBack: {},
            primaryTitle: "Tiếp tục",
            isPrimaryEnabled: !store.selectedTopicKeys.isEmpty,
            onPrimary: onNext,
            onSkip: onSkip
        ) {
            LazyVStack(spacing: Spacing.md) {
                if store.isLoadingCatalog {
                    NoraLoadingMark(size: 28)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, Spacing.xxl)
                } else if let error = store.catalogError {
                    VStack(spacing: Spacing.md) {
                        Label(error, systemImage: "exclamationmark.triangle.fill")
                            .font(.noraSupporting)
                            .foregroundStyle(Color.noraWarning)
                        Button("Thử lại") { Task { await store.loadCatalog() } }
                            .buttonStyle(.noraSecondary)
                    }
                    .frame(maxWidth: .infinity)
                    .noraSurfaceCard()
                } else {
                    ForEach(store.catalog) { item in
                        TopicChoiceCard(
                            item: item,
                            isSelected: store.selectedTopicKeys.contains(item.key)
                        ) {
                            Haptics.play(.selection)
                            store.toggleTopic(item.key)
                        }
                    }
                }
            }
        }
    }

    private var progressValue: Double {
        Double(OnboardingStep.workAndInterests.progressIndex) / Double(OnboardingStep.allCases.count - 1)
    }
}

private struct TopicChoiceCard: View {
    let item: TopicCatalogItem
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(alignment: .top, spacing: Spacing.md) {
                Image(systemName: item.symbol)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(isSelected ? Color.noraAccent : Color.noraTextSecondary)
                    .frame(width: TouchTarget.minimum, height: TouchTarget.minimum)
                    .background(Color.white.opacity(0.08), in: Circle())

                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text(item.name)
                        .font(.noraCardTitle)
                        .foregroundStyle(Color.noraTextPrimary)
                    Text(item.description)
                        .font(.noraSupporting)
                        .foregroundStyle(Color.noraTextSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: Spacing.sm)

                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 21))
                    .foregroundStyle(isSelected ? Color.noraAccent : Color.noraTextTertiary)
            }
            .padding(Spacing.base)
            .background(
                isSelected ? Color.noraGlassSelected : Color.noraSurface,
                in: RoundedRectangle(cornerRadius: Radius.md, style: .continuous)
            )
            .overlay {
                RoundedRectangle(cornerRadius: Radius.md, style: .continuous)
                    .strokeBorder(isSelected ? Color.noraAccent : .white.opacity(0.18), lineWidth: 1)
            }
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

#Preview {
    WorkInterestsStepView(store: OnboardingStore(environment: .preview(), onComplete: {}), onNext: {}, onSkip: {})
}
