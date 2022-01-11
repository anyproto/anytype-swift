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
  internal enum BlockBackground {
    static let amber = ColorAsset(name: "BlockBackground/amber")
    static let blue = ColorAsset(name: "BlockBackground/blue")
    static let green = ColorAsset(name: "BlockBackground/green")
    static let grey = ColorAsset(name: "BlockBackground/grey")
    static let pink = ColorAsset(name: "BlockBackground/pink")
    static let purple = ColorAsset(name: "BlockBackground/purple")
    static let red = ColorAsset(name: "BlockBackground/red")
    static let sky = ColorAsset(name: "BlockBackground/sky")
    static let teal = ColorAsset(name: "BlockBackground/teal")
    static let yellow = ColorAsset(name: "BlockBackground/yellow")
  }
  internal enum System {
    static let amber = ColorAsset(name: "System/amber")
    static let amber125 = ColorAsset(name: "System/amber125")
    static let amber25 = ColorAsset(name: "System/amber25")
    static let amber50 = ColorAsset(name: "System/amber50")
    static let amber80 = ColorAsset(name: "System/amber80")
    static let blue = ColorAsset(name: "System/blue")
    static let green = ColorAsset(name: "System/green")
    static let grey = ColorAsset(name: "System/grey")
    static let pink = ColorAsset(name: "System/pink")
    static let purple = ColorAsset(name: "System/purple")
    static let red = ColorAsset(name: "System/red")
    static let sky = ColorAsset(name: "System/sky")
    static let teal = ColorAsset(name: "System/teal")
    static let yellow = ColorAsset(name: "System/yellow")
  }
  internal enum TagBackground {
    static let amber = ColorAsset(name: "TagBackground/amber")
    static let blue = ColorAsset(name: "TagBackground/blue")
    static let green = ColorAsset(name: "TagBackground/green")
    static let grey = ColorAsset(name: "TagBackground/grey")
    static let pink = ColorAsset(name: "TagBackground/pink")
    static let purple = ColorAsset(name: "TagBackground/purple")
    static let red = ColorAsset(name: "TagBackground/red")
    static let sky = ColorAsset(name: "TagBackground/sky")
    static let teal = ColorAsset(name: "TagBackground/teal")
    static let yellow = ColorAsset(name: "TagBackground/yellow")
  }
  internal enum Text {
    static let amber = ColorAsset(name: "Text/amber")
    static let blue = ColorAsset(name: "Text/blue")
    static let green = ColorAsset(name: "Text/green")
    static let grey = ColorAsset(name: "Text/grey")
    static let pink = ColorAsset(name: "Text/pink")
    static let purple = ColorAsset(name: "Text/purple")
    static let red = ColorAsset(name: "Text/red")
    static let sky = ColorAsset(name: "Text/sky")
    static let teal = ColorAsset(name: "Text/teal")
    static let yellow = ColorAsset(name: "Text/yellow")
  }

  // MARK: - Backgound
  static let backgroundBlurred = ColorAsset(name: "backgroundBlurred")
  static let backgroundDashboard = ColorAsset(name: "backgroundDashboard")
  static let backgroundPrimary = ColorAsset(name: "backgroundPrimary")
  static let backgroundSecondary = ColorAsset(name: "backgroundSecondary")
  static let backgroundSelected = ColorAsset(name: "backgroundSelected")

  // MARK: - Custom
  static let divider = ColorAsset(name: "divider")
  static let dividerSecondary = ColorAsset(name: "dividerSecondary")
  static let stroke = ColorAsset(name: "stroke")
  static let toastBackground = ColorAsset(name: "toastBackground")

  // MARK: - Grayscale
  static let grayscale10 = ColorAsset(name: "grayscale10")
  static let grayscale30 = ColorAsset(name: "grayscale30")
  static let grayscale50 = ColorAsset(name: "grayscale50")
  static let grayscale70 = ColorAsset(name: "grayscale70")
  static let grayscale90 = ColorAsset(name: "grayscale90")
  static let grayscaleWhite = ColorAsset(name: "grayscaleWhite")

  // MARK: - Stroke
  static let strokePrimary = ColorAsset(name: "strokePrimary")
  static let strokeSecondary = ColorAsset(name: "strokeSecondary")
  static let strokeTertiary = ColorAsset(name: "strokeTertiary")

  // MARK: - Text
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
