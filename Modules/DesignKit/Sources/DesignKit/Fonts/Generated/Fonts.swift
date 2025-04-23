// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

#if os(macOS)
  import AppKit.NSFont
#elseif os(iOS) || os(tvOS) || os(watchOS)
  import UIKit.UIFont
#endif
#if canImport(SwiftUI)
  import SwiftUI
#endif

// swiftlint:disable superfluous_disable_command file_length implicit_return

// MARK: - Fonts

// swiftlint:disable identifier_name line_length type_body_length
public enum FontFamily {
  public enum IBMPlexMono {
    public static let regular = FontConvertible(name: "IBMPlexMono", family: "IBM Plex Mono", path: "IBMPlexMono-Regular.ttf")
    public static let bold = FontConvertible(name: "IBMPlexMono-Bold", family: "IBM Plex Mono", path: "IBMPlexMono-Bold.ttf")
    public static let boldItalic = FontConvertible(name: "IBMPlexMono-BoldItalic", family: "IBM Plex Mono", path: "IBMPlexMono-BoldItalic.ttf")
    public static let italic = FontConvertible(name: "IBMPlexMono-Italic", family: "IBM Plex Mono", path: "IBMPlexMono-Italic.ttf")
    public static let all: [FontConvertible] = [regular, bold, boldItalic, italic]
  }
  public enum Inter {
    public static let regular = FontConvertible(name: "Inter", family: "Inter", path: "Inter.ttf")
    public static let black = FontConvertible(name: "Inter_Black", family: "Inter", path: "Inter.ttf")
    public static let blackItalic = FontConvertible(name: "Inter_Black-Italic", family: "Inter", path: "Inter.ttf")
    public static let bold = FontConvertible(name: "Inter_Bold", family: "Inter", path: "Inter.ttf")
    public static let boldItalic = FontConvertible(name: "Inter_Bold-Italic", family: "Inter", path: "Inter.ttf")
    public static let extraBold = FontConvertible(name: "Inter_Extra-Bold", family: "Inter", path: "Inter.ttf")
    public static let extraBoldItalic = FontConvertible(name: "Inter_Extra-Bold-Italic", family: "Inter", path: "Inter.ttf")
    public static let extraLight = FontConvertible(name: "Inter_Extra-Light", family: "Inter", path: "Inter.ttf")
    public static let extraLightItalic = FontConvertible(name: "Inter_Extra-Light-Italic", family: "Inter", path: "Inter.ttf")
    public static let italic = FontConvertible(name: "Inter_Italic", family: "Inter", path: "Inter.ttf")
    public static let light = FontConvertible(name: "Inter_Light", family: "Inter", path: "Inter.ttf")
    public static let lightItalic = FontConvertible(name: "Inter_Light-Italic", family: "Inter", path: "Inter.ttf")
    public static let medium = FontConvertible(name: "Inter_Medium", family: "Inter", path: "Inter.ttf")
    public static let mediumItalic = FontConvertible(name: "Inter_Medium-Italic", family: "Inter", path: "Inter.ttf")
    public static let semiBold = FontConvertible(name: "Inter_Semi-Bold", family: "Inter", path: "Inter.ttf")
    public static let semiBoldItalic = FontConvertible(name: "Inter_Semi-Bold-Italic", family: "Inter", path: "Inter.ttf")
    public static let thin = FontConvertible(name: "Inter_Thin", family: "Inter", path: "Inter.ttf")
    public static let thinItalic = FontConvertible(name: "Inter_Thin-Italic", family: "Inter", path: "Inter.ttf")
    public static let all: [FontConvertible] = [regular, black, blackItalic, bold, boldItalic, extraBold, extraBoldItalic, extraLight, extraLightItalic, italic, light, lightItalic, medium, mediumItalic, semiBold, semiBoldItalic, thin, thinItalic]
  }
  public enum RiccioneXlight {
    public static let regular = FontConvertible(name: "Riccione-Xlight", family: "Riccione-Xlight", path: "Riccione-Xlight.ttf")
    public static let all: [FontConvertible] = [regular]
  }
  public static let allCustomFonts: [FontConvertible] = [IBMPlexMono.all, Inter.all, RiccioneXlight.all].flatMap { $0 }
  public static func registerAllCustomFonts() {
    allCustomFonts.forEach { $0.register() }
  }
}
// swiftlint:enable identifier_name line_length type_body_length

// MARK: - Implementation Details

public struct FontConvertible: Equatable, Hashable, Sendable {
  public let name: String
  public let family: String
  public let path: String

  #if os(macOS)
  public typealias Font = NSFont
  #elseif os(iOS) || os(tvOS) || os(watchOS)
  public typealias Font = UIFont
  #endif

  public func font(size: CGFloat) -> Font {
    guard let font = Font(font: self, size: size) else {
      fatalError("Unable to initialize font '\(name)' (\(family))")
    }
    return font
  }

  #if canImport(SwiftUI)
  @available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, *)
  public func swiftUIFont(size: CGFloat) -> SwiftUI.Font {
    return SwiftUI.Font.custom(self, size: size)
  }

  @available(iOS 14.0, tvOS 14.0, watchOS 7.0, macOS 11.0, *)
  public func swiftUIFont(fixedSize: CGFloat) -> SwiftUI.Font {
    return SwiftUI.Font.custom(self, fixedSize: fixedSize)
  }

  @available(iOS 14.0, tvOS 14.0, watchOS 7.0, macOS 11.0, *)
  public func swiftUIFont(size: CGFloat, relativeTo textStyle: SwiftUI.Font.TextStyle) -> SwiftUI.Font {
    return SwiftUI.Font.custom(self, size: size, relativeTo: textStyle)
  }
  #endif

  public func register() {
    // swiftlint:disable:next conditional_returns_on_newline
    guard let url = url else { return }
    CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
  }

  fileprivate func registerIfNeeded() {
    #if os(iOS) || os(tvOS) || os(watchOS)
    if !UIFont.fontNames(forFamilyName: family).contains(name) {
      register()
    }
    #elseif os(macOS)
    if let url = url, CTFontManagerGetScopeForURL(url as CFURL) == .none {
      register()
    }
    #endif
  }

  fileprivate var url: URL? {
    // swiftlint:disable:next implicit_return
    return BundleToken.bundle.url(forResource: path, withExtension: nil)
  }
}

public extension FontConvertible.Font {
  convenience init?(font: FontConvertible, size: CGFloat) {
    font.registerIfNeeded()
    self.init(name: font.name, size: size)
  }
}

#if canImport(SwiftUI)
@available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, *)
public extension SwiftUI.Font {
  static func custom(_ font: FontConvertible, size: CGFloat) -> SwiftUI.Font {
    font.registerIfNeeded()
    return custom(font.name, size: size)
  }
}

@available(iOS 14.0, tvOS 14.0, watchOS 7.0, macOS 11.0, *)
public extension SwiftUI.Font {
  static func custom(_ font: FontConvertible, fixedSize: CGFloat) -> SwiftUI.Font {
    font.registerIfNeeded()
    return custom(font.name, fixedSize: fixedSize)
  }

  static func custom(
    _ font: FontConvertible,
    size: CGFloat,
    relativeTo textStyle: SwiftUI.Font.TextStyle
  ) -> SwiftUI.Font {
    font.registerIfNeeded()
    return custom(font.name, size: size, relativeTo: textStyle)
  }
}
#endif

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
