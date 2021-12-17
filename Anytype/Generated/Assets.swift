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
  static let backgroundBlurred = ColorAsset(name: "backgroundBlurred")
  static let backgroundDashboard = ColorAsset(name: "backgroundDashboard")
  static let backgroundPrimary = ColorAsset(name: "backgroundPrimary")
  static let backgroundSecondary = ColorAsset(name: "backgroundSecondary")
  static let backgroundSelected = ColorAsset(name: "backgroundSelected")
  static let divider = ColorAsset(name: "divider")
  static let dividerSecondary = ColorAsset(name: "dividerSecondary")
  static let stroke = ColorAsset(name: "stroke")
  static let toastBackground = ColorAsset(name: "toastBackground")
  static let darkAmber = ColorAsset(name: "darkAmber")
  static let darkBlue = ColorAsset(name: "darkBlue")
  static let darkColdGray = ColorAsset(name: "darkColdGray")
  static let darkGreen = ColorAsset(name: "darkGreen")
  static let darkLemon = ColorAsset(name: "darkLemon")
  static let darkPink = ColorAsset(name: "darkPink")
  static let darkPurple = ColorAsset(name: "darkPurple")
  static let darkRed = ColorAsset(name: "darkRed")
  static let darkTeal = ColorAsset(name: "darkTeal")
  static let darkUltramarine = ColorAsset(name: "darkUltramarine")
  static let grayscale10 = ColorAsset(name: "grayscale10")
  static let grayscale30 = ColorAsset(name: "grayscale30")
  static let grayscale50 = ColorAsset(name: "grayscale50")
  static let grayscale70 = ColorAsset(name: "grayscale70")
  static let grayscale90 = ColorAsset(name: "grayscale90")
  static let grayscaleWhite = ColorAsset(name: "grayscaleWhite")
  static let lightAmber = ColorAsset(name: "lightAmber")
  static let lightBlue = ColorAsset(name: "lightBlue")
  static let lightColdGray = ColorAsset(name: "lightColdGray")
  static let lightGreen = ColorAsset(name: "lightGreen")
  static let lightLemon = ColorAsset(name: "lightLemon")
  static let lightPink = ColorAsset(name: "lightPink")
  static let lightPurple = ColorAsset(name: "lightPurple")
  static let lightRed = ColorAsset(name: "lightRed")
  static let lightTeal = ColorAsset(name: "lightTeal")
  static let lightUltramarine = ColorAsset(name: "lightUltramarine")
  static let pureAmber = ColorAsset(name: "pureAmber")
  static let pureBlue = ColorAsset(name: "pureBlue")
  static let pureGreen = ColorAsset(name: "pureGreen")
  static let pureLemon = ColorAsset(name: "pureLemon")
  static let purePink = ColorAsset(name: "purePink")
  static let purePurple = ColorAsset(name: "purePurple")
  static let pureRed = ColorAsset(name: "pureRed")
  static let pureTeal = ColorAsset(name: "pureTeal")
  static let pureUltramarine = ColorAsset(name: "pureUltramarine")
  static let strokePrimary = ColorAsset(name: "strokePrimary")
  static let strokeSecondary = ColorAsset(name: "strokeSecondary")
  static let strokeTertiary = ColorAsset(name: "strokeTertiary")
  static let textPrimary = ColorAsset(name: "textPrimary")
  static let textSecondary = ColorAsset(name: "textSecondary")
  static let textTertiary = ColorAsset(name: "textTertiary")
  static let buttonInactive = ColorAsset(name: "buttonInactive")
  static let buttonSecondaryPressed = ColorAsset(name: "buttonSecondaryPressed")
  static let buttonSelected = ColorAsset(name: "buttonSelected")
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
