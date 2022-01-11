import UIKit

extension UIColor {
    enum BlockBackground: ComponentColor {
      typealias T = UIColor
      internal static let amber = UIColor(asset: Asset.BlockBackground.amber)
      internal static let blue = UIColor(asset: Asset.BlockBackground.blue)
      internal static let green = UIColor(asset: Asset.BlockBackground.green)
      internal static let grey = UIColor(asset: Asset.BlockBackground.grey)
      internal static let pink = UIColor(asset: Asset.BlockBackground.pink)
      internal static let purple = UIColor(asset: Asset.BlockBackground.purple)
      internal static let red = UIColor(asset: Asset.BlockBackground.red)
      internal static let sky = UIColor(asset: Asset.BlockBackground.sky)
      internal static let teal = UIColor(asset: Asset.BlockBackground.teal)
      internal static let yellow = UIColor(asset: Asset.BlockBackground.yellow)
    }
    enum System: ComponentColor {
      typealias T = UIColor
      internal static let amber = UIColor(asset: Asset.System.amber)
      internal static let amber125 = UIColor(asset: Asset.System.amber125)
      internal static let amber25 = UIColor(asset: Asset.System.amber25)
      internal static let amber50 = UIColor(asset: Asset.System.amber50)
      internal static let amber80 = UIColor(asset: Asset.System.amber80)
      internal static let blue = UIColor(asset: Asset.System.blue)
      internal static let green = UIColor(asset: Asset.System.green)
      internal static let grey = UIColor(asset: Asset.System.grey)
      internal static let pink = UIColor(asset: Asset.System.pink)
      internal static let purple = UIColor(asset: Asset.System.purple)
      internal static let red = UIColor(asset: Asset.System.red)
      internal static let sky = UIColor(asset: Asset.System.sky)
      internal static let teal = UIColor(asset: Asset.System.teal)
      internal static let yellow = UIColor(asset: Asset.System.yellow)
    }
    enum TagBackground: ComponentColor {
      typealias T = UIColor
      internal static let amber = UIColor(asset: Asset.TagBackground.amber)
      internal static let blue = UIColor(asset: Asset.TagBackground.blue)
      internal static let green = UIColor(asset: Asset.TagBackground.green)
      internal static let grey = UIColor(asset: Asset.TagBackground.grey)
      internal static let pink = UIColor(asset: Asset.TagBackground.pink)
      internal static let purple = UIColor(asset: Asset.TagBackground.purple)
      internal static let red = UIColor(asset: Asset.TagBackground.red)
      internal static let sky = UIColor(asset: Asset.TagBackground.sky)
      internal static let teal = UIColor(asset: Asset.TagBackground.teal)
      internal static let yellow = UIColor(asset: Asset.TagBackground.yellow)
    }
    enum Text: ComponentColor {
      typealias T = UIColor
      internal static let amber = UIColor(asset: Asset.Text.amber)
      internal static let blue = UIColor(asset: Asset.Text.blue)
      internal static let green = UIColor(asset: Asset.Text.green)
      internal static let grey = UIColor(asset: Asset.Text.grey)
      internal static let pink = UIColor(asset: Asset.Text.pink)
      internal static let purple = UIColor(asset: Asset.Text.purple)
      internal static let red = UIColor(asset: Asset.Text.red)
      internal static let sky = UIColor(asset: Asset.Text.sky)
      internal static let teal = UIColor(asset: Asset.Text.teal)
      internal static let yellow = UIColor(asset: Asset.Text.yellow)
    }
    // MARK: - Backgound
    internal static let backgroundBlurred = UIColor(asset: Asset.backgroundBlurred)
    internal static let backgroundDashboard = UIColor(asset: Asset.backgroundDashboard)
    internal static let backgroundPrimary = UIColor(asset: Asset.backgroundPrimary)
    internal static let backgroundSecondary = UIColor(asset: Asset.backgroundSecondary)
    internal static let backgroundSelected = UIColor(asset: Asset.backgroundSelected)
    // MARK: - Custom
    internal static let divider = UIColor(asset: Asset.divider)
    internal static let dividerSecondary = UIColor(asset: Asset.dividerSecondary)
    internal static let stroke = UIColor(asset: Asset.stroke)
    internal static let toastBackground = UIColor(asset: Asset.toastBackground)
    // MARK: - Grayscale
    internal static let grayscale10 = UIColor(asset: Asset.grayscale10)
    internal static let grayscale30 = UIColor(asset: Asset.grayscale30)
    internal static let grayscale50 = UIColor(asset: Asset.grayscale50)
    internal static let grayscale70 = UIColor(asset: Asset.grayscale70)
    internal static let grayscale90 = UIColor(asset: Asset.grayscale90)
    internal static let grayscaleWhite = UIColor(asset: Asset.grayscaleWhite)
    // MARK: - Stroke
    internal static let strokePrimary = UIColor(asset: Asset.strokePrimary)
    internal static let strokeSecondary = UIColor(asset: Asset.strokeSecondary)
    internal static let strokeTertiary = UIColor(asset: Asset.strokeTertiary)
    // MARK: - Text
    internal static let textPrimary = UIColor(asset: Asset.textPrimary)
    internal static let textSecondary = UIColor(asset: Asset.textSecondary)
    internal static let textTertiary = UIColor(asset: Asset.textTertiary)
    internal static let buttonInactive = UIColor(asset: Asset.buttonInactive)
    internal static let buttonSecondaryPressed = UIColor(asset: Asset.buttonSecondaryPressed)
    internal static let buttonSelected = UIColor(asset: Asset.buttonSelected)
}
