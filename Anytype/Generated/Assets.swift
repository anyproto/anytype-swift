// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

#if os(macOS)
  import AppKit
#elseif os(iOS)
  import UIKit
#elseif os(tvOS) || os(watchOS)
  import UIKit
#endif

// Deprecated typealiases
@available(*, deprecated, renamed: "ColorAsset.Color", message: "This typealias will be removed in SwiftGen 7.0")
internal typealias AssetColorTypeAlias = ColorAsset.Color

// swiftlint:disable superfluous_disable_command file_length implicit_return

// MARK: - Asset Catalogs

// swiftlint:disable identifier_name line_length nesting type_body_length type_name
internal enum Asset {
  internal static let backgroundBlurred = ColorAsset(name: "backgroundBlurred")
  internal static let backgroundDashboard = ColorAsset(name: "backgroundDashboard")
  internal static let backgroundPrimary = ColorAsset(name: "backgroundPrimary")
  internal static let backgroundSecondary = ColorAsset(name: "backgroundSecondary")
  internal static let backgroundSelected = ColorAsset(name: "backgroundSelected")
  internal static let divider = ColorAsset(name: "divider")
  internal static let dividerSecondary = ColorAsset(name: "dividerSecondary")
  internal static let stroke = ColorAsset(name: "stroke")
  internal static let toastBackground = ColorAsset(name: "toastBackground")
  internal static let darkAmber = ColorAsset(name: "darkAmber")
  internal static let darkBlue = ColorAsset(name: "darkBlue")
  internal static let darkColdGray = ColorAsset(name: "darkColdGray")
  internal static let darkGreen = ColorAsset(name: "darkGreen")
  internal static let darkLemon = ColorAsset(name: "darkLemon")
  internal static let darkPink = ColorAsset(name: "darkPink")
  internal static let darkPurple = ColorAsset(name: "darkPurple")
  internal static let darkRed = ColorAsset(name: "darkRed")
  internal static let darkTeal = ColorAsset(name: "darkTeal")
  internal static let darkUltramarine = ColorAsset(name: "darkUltramarine")
  internal static let grayscale10 = ColorAsset(name: "grayscale10")
  internal static let grayscale30 = ColorAsset(name: "grayscale30")
  internal static let grayscale50 = ColorAsset(name: "grayscale50")
  internal static let grayscale70 = ColorAsset(name: "grayscale70")
  internal static let grayscale90 = ColorAsset(name: "grayscale90")
  internal static let grayscaleWhite = ColorAsset(name: "grayscaleWhite")
  internal static let lightAmber = ColorAsset(name: "lightAmber")
  internal static let lightBlue = ColorAsset(name: "lightBlue")
  internal static let lightColdGray = ColorAsset(name: "lightColdGray")
  internal static let lightGreen = ColorAsset(name: "lightGreen")
  internal static let lightLemon = ColorAsset(name: "lightLemon")
  internal static let lightPink = ColorAsset(name: "lightPink")
  internal static let lightPurple = ColorAsset(name: "lightPurple")
  internal static let lightRed = ColorAsset(name: "lightRed")
  internal static let lightTeal = ColorAsset(name: "lightTeal")
  internal static let lightUltramarine = ColorAsset(name: "lightUltramarine")
  internal static let pureAmber = ColorAsset(name: "pureAmber")
  internal static let pureBlue = ColorAsset(name: "pureBlue")
  internal static let pureGreen = ColorAsset(name: "pureGreen")
  internal static let pureLemon = ColorAsset(name: "pureLemon")
  internal static let purePink = ColorAsset(name: "purePink")
  internal static let purePurple = ColorAsset(name: "purePurple")
  internal static let pureRed = ColorAsset(name: "pureRed")
  internal static let pureTeal = ColorAsset(name: "pureTeal")
  internal static let pureUltramarine = ColorAsset(name: "pureUltramarine")
  internal static let strokePrimary = ColorAsset(name: "strokePrimary")
  internal static let strokeSecondary = ColorAsset(name: "strokeSecondary")
  internal static let strokeTertiary = ColorAsset(name: "strokeTertiary")
  internal static let textPrimary = ColorAsset(name: "textPrimary")
  internal static let textSecondary = ColorAsset(name: "textSecondary")
  internal static let textTertiary = ColorAsset(name: "textTertiary")
  internal static let buttonInactive = ColorAsset(name: "buttonInactive")
  internal static let buttonSecondaryPressed = ColorAsset(name: "buttonSecondaryPressed")
  internal static let buttonSelected = ColorAsset(name: "buttonSelected")
}
// swiftlint:enable identifier_name line_length nesting type_body_length type_name

// MARK: - Implementation Details

internal final class ColorAsset {
  internal fileprivate(set) var name: String

  #if os(macOS)
  internal typealias Color = NSColor
  #elseif os(iOS) || os(tvOS) || os(watchOS)
  internal typealias Color = UIColor
  #endif

  @available(iOS 11.0, tvOS 11.0, watchOS 4.0, macOS 10.13, *)
  internal private(set) lazy var color = Color(asset: self)

  #if os(iOS) || os(tvOS)
  @available(iOS 11.0, tvOS 11.0, *)
  internal func color(compatibleWith traitCollection: UITraitCollection) -> Color {
    let bundle = BundleToken.bundle
    guard let color = Color(named: name, in: bundle, compatibleWith: traitCollection) else {
      fatalError("Unable to load color asset named \(name).")
    }
    return color
  }
  #endif

  fileprivate init(name: String) {
    self.name = name
  }
}

internal extension ColorAsset.Color {
  @available(iOS 11.0, tvOS 11.0, watchOS 4.0, macOS 10.13, *)
  convenience init(asset: ColorAsset) {
    let bundle = BundleToken.bundle
    #if os(iOS) || os(tvOS)
    self.init(named: asset.name, in: bundle, compatibleWith: nil)!
    #elseif os(macOS)
    self.init(named: NSColor.Name(asset.name), bundle: bundle)!
    #elseif os(watchOS)
    self.init(named: asset.name)!
    #endif
  }
}

// swiftlint:disable convenience_type
private final class BundleToken {
  static let bundle: Bundle = {
    #if SWIFT_PACKAGE
    return Bundle.module
    #else
    return Bundle(for: BundleToken.self)
    #endif
  }()
}
// swiftlint:enable convenience_type

import SwiftUI
extension Color {
    init(asset: ColorAsset) {
        self.init(asset.name, bundle: BundleToken.bundle)
    }
}
