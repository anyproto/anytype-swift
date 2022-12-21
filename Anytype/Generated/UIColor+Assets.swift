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
      internal static let amber100 = UIColor(asset: Asset.System.amber100)
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
    
    // MARK: - BackgroundNew
    enum BackgroundNew {
      internal static let backgroundBlack = UIColor(asset: Asset.BackgroundNew.backgroundBlack)
      internal static let highlightedOfSelected = UIColor(asset: Asset.BackgroundNew.highlightedOfSelected)
      internal static let primary = UIColor(asset: Asset.BackgroundNew.primary)
      internal static let secondary = UIColor(asset: Asset.BackgroundNew.secondary)
    }
    
    // MARK: - Button
    enum Button {
      internal static let accent = UIColor(asset: Asset.Button.accent)
      internal static let active = UIColor(asset: Asset.Button.active)
      internal static let inactive = UIColor(asset: Asset.Button.inactive)
      internal static let selected = UIColor(asset: Asset.Button.selected)
      internal static let white = UIColor(asset: Asset.Button.white)
    }
    
    // MARK: - Dashboard
    enum Dashboard {
      internal static let card = UIColor(asset: Asset.Dashboard.card)
    }
    
    // MARK: - Shadow
    internal static let shadowPrimary = UIColor(asset: Asset.shadowPrimary)
    
    // MARK: - Stroke
    enum Stroke {
      internal static let primary = UIColor(asset: Asset.Stroke.primary)
      internal static let secondary = UIColor(asset: Asset.Stroke.secondary)
      internal static let tertiary = UIColor(asset: Asset.Stroke.tertiary)
      internal static let transperent = UIColor(asset: Asset.Stroke.transperent)
    }
    
    // MARK: - TextNew
    enum TextNew {
      internal static let primary = UIColor(asset: Asset.TextNew.primary)
      internal static let secondary = UIColor(asset: Asset.TextNew.secondary)
      internal static let tertiary = UIColor(asset: Asset.TextNew.tertiary)
      internal static let white = UIColor(asset: Asset.TextNew.white)
    }
}
