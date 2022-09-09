import SwiftUI

extension Color {

    enum Background: ComponentColor {
    typealias T = Color

      internal static let amber = Color(asset: Asset.Background.amber)
      internal static let blue = Color(asset: Asset.Background.blue)
      internal static let green = Color(asset: Asset.Background.green)
      internal static let grey = Color(asset: Asset.Background.grey)
      internal static let pink = Color(asset: Asset.Background.pink)
      internal static let purple = Color(asset: Asset.Background.purple)
      internal static let red = Color(asset: Asset.Background.red)
      internal static let sky = Color(asset: Asset.Background.sky)
      internal static let teal = Color(asset: Asset.Background.teal)
      internal static let yellow = Color(asset: Asset.Background.yellow)
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

    // MARK: - Additional

    internal static let shimmering = Color(asset: Asset.shimmering)
    // MARK: - Backgound

    internal static let backgroundDashboard = Color(asset: Asset.backgroundDashboard)
    internal static let backgroundPrimary = Color(asset: Asset.backgroundPrimary)
    internal static let backgroundSecondary = Color(asset: Asset.backgroundSecondary)
    internal static let backgroundSelected = Color(asset: Asset.backgroundSelected)
    // MARK: - Button

    internal static let buttonAccent = Color(asset: Asset.buttonAccent)
    internal static let buttonActive = Color(asset: Asset.buttonActive)
    internal static let buttonInactive = Color(asset: Asset.buttonInactive)
    internal static let buttonSelected = Color(asset: Asset.buttonSelected)
    internal static let buttonWhite = Color(asset: Asset.buttonWhite)
    // MARK: - Shadow

    internal static let shadowPrimary = Color(asset: Asset.shadowPrimary)
    // MARK: - Stroke

    internal static let strokePrimary = Color(asset: Asset.strokePrimary)
    internal static let strokeSecondary = Color(asset: Asset.strokeSecondary)
    internal static let strokeTertiary = Color(asset: Asset.strokeTertiary)
    internal static let strokeTransperent = Color(asset: Asset.strokeTransperent)
    // MARK: - Text

    internal static let textPrimary = Color(asset: Asset.textPrimary)
    internal static let textSecondary = Color(asset: Asset.textSecondary)
    internal static let textTertiary = Color(asset: Asset.textTertiary)
    internal static let textWhite = Color(asset: Asset.textWhite)
}
