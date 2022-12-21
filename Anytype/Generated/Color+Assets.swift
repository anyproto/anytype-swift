import SwiftUI

extension Color {
  
    enum Dark: ComponentColor {
      typealias T = Color
      internal static let amber = Color(asset: Asset.Dark.amber)
      internal static let blue = Color(asset: Asset.Dark.blue)
      internal static let green = Color(asset: Asset.Dark.green)
      internal static let grey = Color(asset: Asset.Dark.grey)
      internal static let pink = Color(asset: Asset.Dark.pink)
      internal static let purple = Color(asset: Asset.Dark.purple)
      internal static let red = Color(asset: Asset.Dark.red)
      internal static let sky = Color(asset: Asset.Dark.sky)
      internal static let teal = Color(asset: Asset.Dark.teal)
      internal static let yellow = Color(asset: Asset.Dark.yellow)
    }
    
    enum Light: ComponentColor {
      typealias T = Color
      internal static let amber = Color(asset: Asset.Light.amber)
      internal static let blue = Color(asset: Asset.Light.blue)
      internal static let green = Color(asset: Asset.Light.green)
      internal static let grey = Color(asset: Asset.Light.grey)
      internal static let pink = Color(asset: Asset.Light.pink)
      internal static let purple = Color(asset: Asset.Light.purple)
      internal static let red = Color(asset: Asset.Light.red)
      internal static let sky = Color(asset: Asset.Light.sky)
      internal static let teal = Color(asset: Asset.Light.teal)
      internal static let yellow = Color(asset: Asset.Light.yellow)
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
    
    enum VeryLight: ComponentColor {
      typealias T = Color
      internal static let amber = Color(asset: Asset.VeryLight.amber)
      internal static let blue = Color(asset: Asset.VeryLight.blue)
      internal static let green = Color(asset: Asset.VeryLight.green)
      internal static let grey = Color(asset: Asset.VeryLight.grey)
      internal static let pink = Color(asset: Asset.VeryLight.pink)
      internal static let purple = Color(asset: Asset.VeryLight.purple)
      internal static let red = Color(asset: Asset.VeryLight.red)
      internal static let sky = Color(asset: Asset.VeryLight.sky)
      internal static let teal = Color(asset: Asset.VeryLight.teal)
      internal static let yellow = Color(asset: Asset.VeryLight.yellow)
    }
  
    // MARK: - Additional
    internal static let shimmering = Color(asset: Asset.shimmering)
    
    // MARK: - Background
    enum Background {
      internal static let backgroundBlack = Color(asset: Asset.Background.backgroundBlack)
      internal static let highlightedOfSelected = Color(asset: Asset.Background.highlightedOfSelected)
      internal static let primary = Color(asset: Asset.Background.primary)
      internal static let secondary = Color(asset: Asset.Background.secondary)
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
    
    // MARK: - Text
    enum Text {
      internal static let primary = Color(asset: Asset.Text.primary)
      internal static let secondary = Color(asset: Asset.Text.secondary)
      internal static let tertiary = Color(asset: Asset.Text.tertiary)
      internal static let white = Color(asset: Asset.Text.white)
    }
}
