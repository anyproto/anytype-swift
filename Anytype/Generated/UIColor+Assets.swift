import UIKit

extension UIColor {
    enum Background: ComponentColor {
      typealias T = UIColor
      internal static let amber = UIColor(asset: Asset.Background.amber)
      internal static let blue = UIColor(asset: Asset.Background.blue)
      internal static let green = UIColor(asset: Asset.Background.green)
      internal static let grey = UIColor(asset: Asset.Background.grey)
      internal static let pink = UIColor(asset: Asset.Background.pink)
      internal static let purple = UIColor(asset: Asset.Background.purple)
      internal static let red = UIColor(asset: Asset.Background.red)
      internal static let sky = UIColor(asset: Asset.Background.sky)
      internal static let teal = UIColor(asset: Asset.Background.teal)
      internal static let yellow = UIColor(asset: Asset.Background.yellow)
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
    // MARK: - Additional
    internal static let shimmering = UIColor(asset: Asset.shimmering)
    // MARK: - Backgound
    internal static let backgroundDashboard = UIColor(asset: Asset.backgroundDashboard)
    internal static let backgroundPrimary = UIColor(asset: Asset.backgroundPrimary)
    internal static let backgroundSecondary = UIColor(asset: Asset.backgroundSecondary)
    internal static let backgroundSelected = UIColor(asset: Asset.backgroundSelected)
    // MARK: - Button
    internal static let buttonAccent = UIColor(asset: Asset.buttonAccent)
    internal static let buttonActive = UIColor(asset: Asset.buttonActive)
    internal static let buttonInactive = UIColor(asset: Asset.buttonInactive)
    internal static let buttonSelected = UIColor(asset: Asset.buttonSelected)
    internal static let buttonWhite = UIColor(asset: Asset.buttonWhite)
    // MARK: - Shadow
    internal static let shadowPrimary = UIColor(asset: Asset.shadowPrimary)
    // MARK: - Stroke
    internal static let strokePrimary = UIColor(asset: Asset.strokePrimary)
    internal static let strokeSecondary = UIColor(asset: Asset.strokeSecondary)
    internal static let strokeTertiary = UIColor(asset: Asset.strokeTertiary)
    internal static let strokeTransperent = UIColor(asset: Asset.strokeTransperent)
    // MARK: - Text
    internal static let textPrimary = UIColor(asset: Asset.textPrimary)
    internal static let textSecondary = UIColor(asset: Asset.textSecondary)
    internal static let textTertiary = UIColor(asset: Asset.textTertiary)
    internal static let textWhite = UIColor(asset: Asset.textWhite)
}
