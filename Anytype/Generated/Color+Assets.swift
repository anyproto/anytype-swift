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
      internal static let amber100 = Color(asset: Asset.System.amber100)
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
    
    // MARK: - BackgroundNew
    enum BackgroundNew {
      internal static let backgroundBlack = Color(asset: Asset.BackgroundNew.backgroundBlack)
      internal static let highlightedOfSelected = Color(asset: Asset.BackgroundNew.highlightedOfSelected)
      internal static let primary = Color(asset: Asset.BackgroundNew.primary)
      internal static let secondary = Color(asset: Asset.BackgroundNew.secondary)
    }
    
    // MARK: - Button
    enum Button {
      internal static let accent = Color(asset: Asset.Button.accent)
      internal static let active = Color(asset: Asset.Button.active)
      internal static let inactive = Color(asset: Asset.Button.inactive)
      internal static let selected = Color(asset: Asset.Button.selected)
      internal static let white = Color(asset: Asset.Button.white)
    }
    
    // MARK: - Dashboard
    enum Dashboard {
      internal static let card = Color(asset: Asset.Dashboard.card)
    }
    
    // MARK: - Shadow
    internal static let shadowPrimary = Color(asset: Asset.shadowPrimary)
    
    // MARK: - Stroke
    enum Stroke {
      internal static let primary = Color(asset: Asset.Stroke.primary)
      internal static let secondary = Color(asset: Asset.Stroke.secondary)
      internal static let tertiary = Color(asset: Asset.Stroke.tertiary)
      internal static let transperent = Color(asset: Asset.Stroke.transperent)
    }
    
    // MARK: - TextNew
    enum TextNew {
      internal static let primary = Color(asset: Asset.TextNew.primary)
      internal static let secondary = Color(asset: Asset.TextNew.secondary)
      internal static let tertiary = Color(asset: Asset.TextNew.tertiary)
      internal static let white = Color(asset: Asset.TextNew.white)
    }
}
