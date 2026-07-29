import Foundation
#if canImport(DeveloperToolsSupport)
import DeveloperToolsSupport
#endif

#if SWIFT_PACKAGE
private let resourceBundle = Foundation.Bundle.module
#else
private class ResourceBundleClass {}
private let resourceBundle = Foundation.Bundle(for: ResourceBundleClass.self)
#endif

// MARK: - Color Symbols -

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension DeveloperToolsSupport.ColorResource {

}

// MARK: - Image Symbols -

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension DeveloperToolsSupport.ImageResource {

    /// The "MistyForest" asset catalog image resource.
    static let mistyForest = DeveloperToolsSupport.ImageResource(name: "MistyForest", bundle: resourceBundle)

    /// The "MoonlitCoast" asset catalog image resource.
    static let moonlitCoast = DeveloperToolsSupport.ImageResource(name: "MoonlitCoast", bundle: resourceBundle)

    /// The "MountainDusk" asset catalog image resource.
    static let mountainDusk = DeveloperToolsSupport.ImageResource(name: "MountainDusk", bundle: resourceBundle)

    /// The "NoraColorIcon" asset catalog image resource.
    static let noraColorIcon = DeveloperToolsSupport.ImageResource(name: "NoraColorIcon", bundle: resourceBundle)

    /// The "WelcomeCity" asset catalog image resource.
    static let welcomeCity = DeveloperToolsSupport.ImageResource(name: "WelcomeCity", bundle: resourceBundle)

}

