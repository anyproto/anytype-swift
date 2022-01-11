import SwiftUI

extension Color {
    enum BlockBackground: ComponentColor {
      typealias T = Color
      internal static let amber = Color(asset: Asset.BlockBackground.amber)
      internal static let blue = Color(asset: Asset.BlockBackground.blue)
      internal static let green = Color(asset: Asset.BlockBackground.green)
      internal static let grey = Color(asset: Asset.BlockBackground.grey)
      internal static let pink = Color(asset: Asset.BlockBackground.pink)
      internal static let purple = Color(asset: Asset.BlockBackground.purple)
      internal static let red = Color(asset: Asset.BlockBackground.red)
      internal static let sky = Color(asset: Asset.BlockBackground.sky)
      internal static let teal = Color(asset: Asset.BlockBackground.teal)
      internal static let yellow = Color(asset: Asset.BlockBackground.yellow)
    }
    enum System: ComponentColor {
      typealias T = Color
      internal static let amber = Color(asset: Asset.System.amber)
      internal static let amber125 = Color(asset: Asset.System.amber125)
      internal static let amber25 = Color(asset: Asset.System.amber25)
      internal static let amber50 = Color(asset: Asset.System.amber50)
      internal static let amber80 = Color(asset: Asset.System.amber80)
      internal static let blue = Color(asset: Asset.System.blue)
      internal static let green = Color(asset: Asset.System.green)
      internal static let grey = Color(asset: Asset.System.grey)
      internal static let pink = Color(asset: Asset.System.pink)
      internal static let purple = Color(asset: Asset.System.purple)
      internal static let red = Color(asset: Asset.System.red)
      internal static let sky = Color(asset: Asset.System.sky)
      internal static let teal = Color(asset: Asset.System.teal)
      internal static let yellow = Color(asset: Asset.System.yellow)
    }
    enum TagBackground: ComponentColor {
      typealias T = Color
      internal static let amber = Color(asset: Asset.TagBackground.amber)
      internal static let blue = Color(asset: Asset.TagBackground.blue)
      internal static let green = Color(asset: Asset.TagBackground.green)
      internal static let grey = Color(asset: Asset.TagBackground.grey)
      internal static let pink = Color(asset: Asset.TagBackground.pink)
      internal static let purple = Color(asset: Asset.TagBackground.purple)
      internal static let red = Color(asset: Asset.TagBackground.red)
      internal static let sky = Color(asset: Asset.TagBackground.sky)
      internal static let teal = Color(asset: Asset.TagBackground.teal)
      internal static let yellow = Color(asset: Asset.TagBackground.yellow)
    }
    enum Text: ComponentColor {
      typealias T = Color
      internal static let amber = Color(asset: Asset.Text.amber)
      internal static let blue = Color(asset: Asset.Text.blue)
      internal static let green = Color(asset: Asset.Text.green)
      internal static let grey = Color(asset: Asset.Text.grey)
      internal static let pink = Color(asset: Asset.Text.pink)
      internal static let purple = Color(asset: Asset.Text.purple)
      internal static let red = Color(asset: Asset.Text.red)
      internal static let sky = Color(asset: Asset.Text.sky)
      internal static let teal = Color(asset: Asset.Text.teal)
      internal static let yellow = Color(asset: Asset.Text.yellow)
    }
    // MARK: - Backgound
    internal static let backgroundBlurred = Color(asset: Asset.backgroundBlurred)
    internal static let backgroundDashboard = Color(asset: Asset.backgroundDashboard)
    internal static let backgroundPrimary = Color(asset: Asset.backgroundPrimary)
    internal static let backgroundSecondary = Color(asset: Asset.backgroundSecondary)
    internal static let backgroundSelected = Color(asset: Asset.backgroundSelected)
    // MARK: - Custom
    internal static let divider = Color(asset: Asset.divider)
    internal static let dividerSecondary = Color(asset: Asset.dividerSecondary)
    internal static let stroke = Color(asset: Asset.stroke)
    internal static let toastBackground = Color(asset: Asset.toastBackground)
    // MARK: - Grayscale
    internal static let grayscale10 = Color(asset: Asset.grayscale10)
    internal static let grayscale30 = Color(asset: Asset.grayscale30)
    internal static let grayscale50 = Color(asset: Asset.grayscale50)
    internal static let grayscale70 = Color(asset: Asset.grayscale70)
    internal static let grayscale90 = Color(asset: Asset.grayscale90)
    internal static let grayscaleWhite = Color(asset: Asset.grayscaleWhite)
    // MARK: - Stroke
    internal static let strokePrimary = Color(asset: Asset.strokePrimary)
    internal static let strokeSecondary = Color(asset: Asset.strokeSecondary)
    internal static let strokeTertiary = Color(asset: Asset.strokeTertiary)
    // MARK: - Text
    internal static let textPrimary = Color(asset: Asset.textPrimary)
    internal static let textSecondary = Color(asset: Asset.textSecondary)
    internal static let textTertiary = Color(asset: Asset.textTertiary)
    internal static let buttonInactive = Color(asset: Asset.buttonInactive)
    internal static let buttonSecondaryPressed = Color(asset: Asset.buttonSecondaryPressed)
    internal static let buttonSelected = Color(asset: Asset.buttonSelected)
}
