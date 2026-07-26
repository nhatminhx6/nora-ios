import SwiftData
import SwiftUI

@main
struct NoraApp: App {
    let modelContainer = NoraModelContainer.live()
    @State private var environment: AppEnvironment
    @State private var localization: LocalizationManager

    init() {
        let container = modelContainer
        let localization = LocalizationManager()
        _localization = State(initialValue: localization)
        _environment = State(initialValue: AppEnvironment(modelContext: container.mainContext, localization: localization))
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(environment)
                .environment(localization)
        }
        .modelContainer(modelContainer)
    }
}
