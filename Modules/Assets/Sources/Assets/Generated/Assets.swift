// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen
// Location: %RepoRoot%/Tools/SwiftGen 

#if os(macOS)
  import AppKit
#elseif os(iOS)
  import UIKit
#elseif os(tvOS) || os(watchOS)
  import UIKit
#endif

// Deprecated typealiases
@available(*, deprecated, renamed: "ColorAsset.Color", message: "This typealias will be removed in SwiftGen 7.0")
public typealias AssetColorTypeAlias = ColorAsset.Color

// swiftlint:disable superfluous_disable_command file_length implicit_return

// MARK: - Asset Catalogs

// swiftlint:disable identifier_name line_length nesting type_body_length type_name
public enum Asset {
  public enum Dark {
    static let blue = ColorAsset(name: "Dark/blue")
    static let green = ColorAsset(name: "Dark/green")
    static let grey = ColorAsset(name: "Dark/grey")
    static let orange = ColorAsset(name: "Dark/orange")
    static let pink = ColorAsset(name: "Dark/pink")
    static let purple = ColorAsset(name: "Dark/purple")
    static let red = ColorAsset(name: "Dark/red")
    static let sky = ColorAsset(name: "Dark/sky")
    static let teal = ColorAsset(name: "Dark/teal")
    static let yellow = ColorAsset(name: "Dark/yellow")
  }
  public enum Light {
    static let blue = ColorAsset(name: "Light/blue")
    static let green = ColorAsset(name: "Light/green")
    static let grey = ColorAsset(name: "Light/grey")
    static let orange = ColorAsset(name: "Light/orange")
    static let pink = ColorAsset(name: "Light/pink")
    static let purple = ColorAsset(name: "Light/purple")
    static let red = ColorAsset(name: "Light/red")
    static let sky = ColorAsset(name: "Light/sky")
    static let teal = ColorAsset(name: "Light/teal")
    static let yellow = ColorAsset(name: "Light/yellow")
  }
  public enum System {
    static let amber100 = ColorAsset(name: "System/amber100")
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
  public enum VeryLight {
    static let blue = ColorAsset(name: "VeryLight/blue")
    static let green = ColorAsset(name: "VeryLight/green")
    static let grey = ColorAsset(name: "VeryLight/grey")
    static let orange = ColorAsset(name: "VeryLight/orange")
    static let pink = ColorAsset(name: "VeryLight/pink")
    static let purple = ColorAsset(name: "VeryLight/purple")
    static let red = ColorAsset(name: "VeryLight/red")
    static let sky = ColorAsset(name: "VeryLight/sky")
    static let teal = ColorAsset(name: "VeryLight/teal")
    static let yellow = ColorAsset(name: "VeryLight/yellow")
  }

  // MARK: - Custom
  public enum Additional {
    public enum Indicator {
      static let selected = ColorAsset(name: "Additional/Indicator/selected")
      static let unselected = ColorAsset(name: "Additional/Indicator/unselected")
    }
    static let messageInputShadow = ColorAsset(name: "Additional/messageInputShadow")
    static let separator = ColorAsset(name: "Additional/separator")
    static let space = ColorAsset(name: "Additional/space")
  }
  public enum Auth {
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
  public enum BackgroundCustom {
    static let black = ColorAsset(name: "BackgroundCustom/black")
    static let material = ColorAsset(name: "BackgroundCustom/material")
  }
  public enum CoverGradients {
    static let blueEnd = ColorAsset(name: "CoverGradients/blueEnd")
    static let bluePinkEnd = ColorAsset(name: "CoverGradients/bluePinkEnd")
    static let bluePinkStart = ColorAsset(name: "CoverGradients/bluePinkStart")
    static let blueStart = ColorAsset(name: "CoverGradients/blueStart")
    static let greenOrangeEnd = ColorAsset(name: "CoverGradients/greenOrangeEnd")
    static let greenOrangeStart = ColorAsset(name: "CoverGradients/greenOrangeStart")
    static let pinkOrangeEnd = ColorAsset(name: "CoverGradients/pinkOrangeEnd")
    static let pinkOrangeStart = ColorAsset(name: "CoverGradients/pinkOrangeStart")
    static let redEnd = ColorAsset(name: "CoverGradients/redEnd")
    static let redStart = ColorAsset(name: "CoverGradients/redStart")
    static let skyEnd = ColorAsset(name: "CoverGradients/skyEnd")
    static let skyStart = ColorAsset(name: "CoverGradients/skyStart")
    static let tealEnd = ColorAsset(name: "CoverGradients/tealEnd")
    static let tealStart = ColorAsset(name: "CoverGradients/tealStart")
    static let yellowEnd = ColorAsset(name: "CoverGradients/yellowEnd")
    static let yellowStart = ColorAsset(name: "CoverGradients/yellowStart")
  }
  public enum Gradients {
    public enum HeaderAlert {
      static let redEnd = ColorAsset(name: "Gradients/HeaderAlert/redEnd")
      static let redStart = ColorAsset(name: "Gradients/HeaderAlert/redStart")
      static let violetEnd = ColorAsset(name: "Gradients/HeaderAlert/violetEnd")
      static let violetStart = ColorAsset(name: "Gradients/HeaderAlert/violetStart")
    }
    public enum UpdateAlert {
      static let darkBlue = ColorAsset(name: "Gradients/UpdateAlert/darkBlue")
      static let green = ColorAsset(name: "Gradients/UpdateAlert/green")
      static let lightBlue = ColorAsset(name: "Gradients/UpdateAlert/lightBlue")
    }
    static let fadingBlue = ColorAsset(name: "Gradients/fadingBlue")
    static let fadingGreen = ColorAsset(name: "Gradients/fadingGreen")
    static let fadingIce = ColorAsset(name: "Gradients/fadingIce")
    static let fadingPink = ColorAsset(name: "Gradients/fadingPink")
    static let fadingPurple = ColorAsset(name: "Gradients/fadingPurple")
    static let fadingRed = ColorAsset(name: "Gradients/fadingRed")
    static let fadingSky = ColorAsset(name: "Gradients/fadingSky")
    static let fadingTeal = ColorAsset(name: "Gradients/fadingTeal")
    static let fadingYellow = ColorAsset(name: "Gradients/fadingYellow")
    static let green = ColorAsset(name: "Gradients/green")
    static let orange = ColorAsset(name: "Gradients/orange")
    static let white = ColorAsset(name: "Gradients/white")
  }
  public enum Launch {
    static let circle = ColorAsset(name: "Launch/circle")
  }
  public enum ModalScreen {
    static let background = ColorAsset(name: "ModalScreen/background")
    static let backgroundWithBlur = ColorAsset(name: "ModalScreen/backgroundWithBlur")
  }
  public enum PushNotifications {
    static let background = ColorAsset(name: "PushNotifications/background")
    static let hiddenText = ColorAsset(name: "PushNotifications/hiddenText")
    static let text = ColorAsset(name: "PushNotifications/text")
  }
  public enum Shadow {
    static let primary = ColorAsset(name: "Shadow/primary")
  }
  public enum Widget {
    static let actionsBackground = ColorAsset(name: "Widget/actionsBackground")
    static let bottomPanel = ColorAsset(name: "Widget/bottomPanel")
    static let divider = ColorAsset(name: "Widget/divider")
    static let inactiveTab = ColorAsset(name: "Widget/inactiveTab")
    static let secondary = ColorAsset(name: "Widget/secondary")
  }

  // MARK: - DesignSystem
  public enum Background {
    public enum Chat {
      static let bubbleFlash = ColorAsset(name: "Background/Chat/bubbleFlash")
      static let bubbleSomeones = ColorAsset(name: "Background/Chat/bubbleSomeones")
      static let bubbleYour = ColorAsset(name: "Background/Chat/bubbleYour")
      static let replySomeones = ColorAsset(name: "Background/Chat/replySomeones")
      static let replyYours = ColorAsset(name: "Background/Chat/replyYours")
      static let whiteTransparent = ColorAsset(name: "Background/Chat/whiteTransparent")
    }
    static let highlightedLight = ColorAsset(name: "Background/highlightedLight")
    static let highlightedMedium = ColorAsset(name: "Background/highlightedMedium")
    static let navigationPanel = ColorAsset(name: "Background/navigationPanel")
    static let primary = ColorAsset(name: "Background/primary")
    static let secondary = ColorAsset(name: "Background/secondary")
    static let widget = ColorAsset(name: "Background/widget")
  }
  public enum Control {
    static let accent100 = ColorAsset(name: "Control/accent100")
    static let accent125 = ColorAsset(name: "Control/accent125")
    static let accent25 = ColorAsset(name: "Control/accent25")
    static let accent50 = ColorAsset(name: "Control/accent50")
    static let accent80 = ColorAsset(name: "Control/accent80")
    static let active = ColorAsset(name: "Control/active")
    static let button = ColorAsset(name: "Control/button")
    static let inactive = ColorAsset(name: "Control/inactive")
    static let transparentActive = ColorAsset(name: "Control/transparentActive")
    static let transparentInactive = ColorAsset(name: "Control/transparentInactive")
    static let white = ColorAsset(name: "Control/white")
  }
  public enum Shape {
    static let primary = ColorAsset(name: "Shape/primary")
    static let secondary = ColorAsset(name: "Shape/secondary")
    static let tertiary = ColorAsset(name: "Shape/tertiary")
    static let transperentPrimary = ColorAsset(name: "Shape/transperentPrimary")
    static let transperentSecondary = ColorAsset(name: "Shape/transperentSecondary")
    static let transperentTertiary = ColorAsset(name: "Shape/transperentTertiary")
  }
  public enum Text {
    static let inversion = ColorAsset(name: "Text/inversion")
    static let primary = ColorAsset(name: "Text/primary")
    static let secondary = ColorAsset(name: "Text/secondary")
    static let tertiary = ColorAsset(name: "Text/tertiary")
    static let white = ColorAsset(name: "Text/white")
  }
}
// swiftlint:enable identifier_name line_length nesting type_body_length type_name

// MARK: - Implementation Details

public final class ColorAsset: Sendable {
  public let name: String

  #if os(macOS)
  public typealias Color = NSColor
  #elseif os(iOS) || os(tvOS) || os(watchOS)
  public typealias Color = UIColor
  #endif

  @available(iOS 11.0, tvOS 11.0, watchOS 4.0, macOS 10.13, *)
  public var color: Color { Color(asset: self) }

  #if os(iOS) || os(tvOS)
  @available(iOS 11.0, tvOS 11.0, *)
  public func color(compatibleWith traitCollection: UITraitCollection) -> Color {
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

public extension ColorAsset.Color {
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
