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
  internal enum Dark {
    static let amber = ColorAsset(name: "Dark/amber")
    static let blue = ColorAsset(name: "Dark/blue")
    static let green = ColorAsset(name: "Dark/green")
    static let grey = ColorAsset(name: "Dark/grey")
    static let pink = ColorAsset(name: "Dark/pink")
    static let purple = ColorAsset(name: "Dark/purple")
    static let red = ColorAsset(name: "Dark/red")
    static let sky = ColorAsset(name: "Dark/sky")
    static let teal = ColorAsset(name: "Dark/teal")
    static let yellow = ColorAsset(name: "Dark/yellow")
  }
  internal enum Light {
    static let amber = ColorAsset(name: "Light/amber")
    static let blue = ColorAsset(name: "Light/blue")
    static let green = ColorAsset(name: "Light/green")
    static let grey = ColorAsset(name: "Light/grey")
    static let pink = ColorAsset(name: "Light/pink")
    static let purple = ColorAsset(name: "Light/purple")
    static let red = ColorAsset(name: "Light/red")
    static let sky = ColorAsset(name: "Light/sky")
    static let teal = ColorAsset(name: "Light/teal")
    static let yellow = ColorAsset(name: "Light/yellow")
  }
  internal enum System {
    static let amber100 = ColorAsset(name: "System/amber100")
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
  internal enum VeryLight {
    static let amber = ColorAsset(name: "VeryLight/amber")
    static let blue = ColorAsset(name: "VeryLight/blue")
    static let green = ColorAsset(name: "VeryLight/green")
    static let grey = ColorAsset(name: "VeryLight/grey")
    static let pink = ColorAsset(name: "VeryLight/pink")
    static let purple = ColorAsset(name: "VeryLight/purple")
    static let red = ColorAsset(name: "VeryLight/red")
    static let sky = ColorAsset(name: "VeryLight/sky")
    static let teal = ColorAsset(name: "VeryLight/teal")
    static let yellow = ColorAsset(name: "VeryLight/yellow")
  }
  internal enum Additional {
    internal enum Indicator {
      static let selected = ColorAsset(name: "Additional/Indicator/selected")
      static let unselected = ColorAsset(name: "Additional/Indicator/unselected")
    }
    static let gradient = ColorAsset(name: "Additional/gradient")
    static let separator = ColorAsset(name: "Additional/separator")
    static let space = ColorAsset(name: "Additional/space")
  }
  internal enum Auth {
    static let body = ColorAsset(name: "Auth/body")
    static let caption = ColorAsset(name: "Auth/caption")
    static let dot = ColorAsset(name: "Auth/dot")
    static let dotSelected = ColorAsset(name: "Auth/dotSelected")
    static let input = ColorAsset(name: "Auth/input")
    static let inputText = ColorAsset(name: "Auth/inputText")
    static let modalBackground = ColorAsset(name: "Auth/modalBackground")
    static let modalContent = ColorAsset(name: "Auth/modalContent")
    static let text = ColorAsset(name: "Auth/text")
  }
  internal enum Background {
    static let black = ColorAsset(name: "Background/black")
    static let highlightedOfSelected = ColorAsset(name: "Background/highlightedOfSelected")
    static let material = ColorAsset(name: "Background/material")
    static let primary = ColorAsset(name: "Background/primary")
    static let secondary = ColorAsset(name: "Background/secondary")
  }
  internal enum BottomAlert {
    static let blueEnd = ColorAsset(name: "BottomAlert/blueEnd")
    static let blueStart = ColorAsset(name: "BottomAlert/blueStart")
    static let greenEnd = ColorAsset(name: "BottomAlert/greenEnd")
    static let greenStart = ColorAsset(name: "BottomAlert/greenStart")
    static let redEnd = ColorAsset(name: "BottomAlert/redEnd")
    static let redStart = ColorAsset(name: "BottomAlert/redStart")
  }
  internal enum Button {
    static let accent = ColorAsset(name: "Button/accent")
    static let active = ColorAsset(name: "Button/active")
    static let button = ColorAsset(name: "Button/button")
    static let inactive = ColorAsset(name: "Button/inactive")
    static let white = ColorAsset(name: "Button/white")
  }
  internal enum Gradients {
    static let blueEnd = ColorAsset(name: "Gradients/blueEnd")
    static let bluePinkEnd = ColorAsset(name: "Gradients/bluePinkEnd")
    static let bluePinkStart = ColorAsset(name: "Gradients/bluePinkStart")
    static let blueStart = ColorAsset(name: "Gradients/blueStart")
    static let fadingBlue = ColorAsset(name: "Gradients/fadingBlue")
    static let fadingGreen = ColorAsset(name: "Gradients/fadingGreen")
    static let fadingPink = ColorAsset(name: "Gradients/fadingPink")
    static let fadingPurple = ColorAsset(name: "Gradients/fadingPurple")
    static let fadingRed = ColorAsset(name: "Gradients/fadingRed")
    static let fadingSky = ColorAsset(name: "Gradients/fadingSky")
    static let fadingTeal = ColorAsset(name: "Gradients/fadingTeal")
    static let fadingYellow = ColorAsset(name: "Gradients/fadingYellow")
    static let greenOrangeEnd = ColorAsset(name: "Gradients/greenOrangeEnd")
    static let greenOrangeStart = ColorAsset(name: "Gradients/greenOrangeStart")
    static let pinkOrangeEnd = ColorAsset(name: "Gradients/pinkOrangeEnd")
    static let pinkOrangeStart = ColorAsset(name: "Gradients/pinkOrangeStart")
    static let redEnd = ColorAsset(name: "Gradients/redEnd")
    static let redStart = ColorAsset(name: "Gradients/redStart")
    static let skyEnd = ColorAsset(name: "Gradients/skyEnd")
    static let skyStart = ColorAsset(name: "Gradients/skyStart")
    static let tealEnd = ColorAsset(name: "Gradients/tealEnd")
    static let tealStart = ColorAsset(name: "Gradients/tealStart")
    static let yellowEnd = ColorAsset(name: "Gradients/yellowEnd")
    static let yellowStart = ColorAsset(name: "Gradients/yellowStart")
  }
  internal enum ModalScreen {
    static let background = ColorAsset(name: "ModalScreen/background")
    static let backgroundWithBlur = ColorAsset(name: "ModalScreen/backgroundWithBlur")
  }
  internal enum Navigation {
    static let background = ColorAsset(name: "Navigation/background")
    static let buttonActive = ColorAsset(name: "Navigation/buttonActive")
    static let buttonInactive = ColorAsset(name: "Navigation/buttonInactive")
  }
  internal enum Shadow {
    static let primary = ColorAsset(name: "Shadow/primary")
  }
  internal enum Shape {
    static let primary = ColorAsset(name: "Shape/primary")
    static let secondary = ColorAsset(name: "Shape/secondary")
    static let tertiary = ColorAsset(name: "Shape/tertiary")
    static let transperent = ColorAsset(name: "Shape/transperent")
  }
  internal enum Text {
    static let labelInversion = ColorAsset(name: "Text/labelInversion")
    static let primary = ColorAsset(name: "Text/primary")
    static let secondary = ColorAsset(name: "Text/secondary")
    static let tertiary = ColorAsset(name: "Text/tertiary")
    static let white = ColorAsset(name: "Text/white")
  }
  internal enum Widget {
    static let actionsBackground = ColorAsset(name: "Widget/actionsBackground")
    static let bottomPanel = ColorAsset(name: "Widget/bottomPanel")
    static let card = ColorAsset(name: "Widget/card")
    static let divider = ColorAsset(name: "Widget/divider")
    static let inactiveTab = ColorAsset(name: "Widget/inactiveTab")
    static let secondary = ColorAsset(name: "Widget/secondary")
  }
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
