import UIKit
import SwiftUI

extension Color {
  
    // MARK: - Dark
    enum Dark {
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
    
    // MARK: - Light
    enum Light {
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
    
    // MARK: - System
    enum System {
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
    
    // MARK: - VeryLight
    enum VeryLight {
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
    enum Additional {
      
      // MARK: - Indicator
      enum Indicator {
        internal static let selected = Color(asset: Asset.Additional.Indicator.selected)
        internal static let unselected = Color(asset: Asset.Additional.Indicator.unselected)
      }
      internal static let gradient = Color(asset: Asset.Additional.gradient)
      internal static let separator = Color(asset: Asset.Additional.separator)
      internal static let space = Color(asset: Asset.Additional.space)
    }
    
    // MARK: - Auth
    enum Auth {
      internal static let body = Color(asset: Asset.Auth.body)
      internal static let caption = Color(asset: Asset.Auth.caption)
      internal static let dot = Color(asset: Asset.Auth.dot)
      internal static let dotSelected = Color(asset: Asset.Auth.dotSelected)
      internal static let input = Color(asset: Asset.Auth.input)
      internal static let inputText = Color(asset: Asset.Auth.inputText)
      internal static let modalBackground = Color(asset: Asset.Auth.modalBackground)
      internal static let modalContent = Color(asset: Asset.Auth.modalContent)
      internal static let text = Color(asset: Asset.Auth.text)
    }
    
    // MARK: - Background
    enum Background {
      internal static let black = Color(asset: Asset.Background.black)
      internal static let highlightedOfSelected = Color(asset: Asset.Background.highlightedOfSelected)
      internal static let material = Color(asset: Asset.Background.material)
      internal static let primary = Color(asset: Asset.Background.primary)
      internal static let secondary = Color(asset: Asset.Background.secondary)
    }
    
    // MARK: - BottomAlert
    enum BottomAlert {
      internal static let blueEnd = Color(asset: Asset.BottomAlert.blueEnd)
      internal static let blueStart = Color(asset: Asset.BottomAlert.blueStart)
      internal static let greenEnd = Color(asset: Asset.BottomAlert.greenEnd)
      internal static let greenStart = Color(asset: Asset.BottomAlert.greenStart)
      internal static let redEnd = Color(asset: Asset.BottomAlert.redEnd)
      internal static let redStart = Color(asset: Asset.BottomAlert.redStart)
    }
    
    // MARK: - Button
    enum Button {
      internal static let accent = Color(asset: Asset.Button.accent)
      internal static let active = Color(asset: Asset.Button.active)
      internal static let button = Color(asset: Asset.Button.button)
      internal static let inactive = Color(asset: Asset.Button.inactive)
      internal static let white = Color(asset: Asset.Button.white)
    }
    
    // MARK: - ModalScreen
    enum ModalScreen {
      internal static let background = Color(asset: Asset.ModalScreen.background)
      internal static let backgroundWithBlur = Color(asset: Asset.ModalScreen.backgroundWithBlur)
    }
    
    // MARK: - Navigation
    enum Navigation {
      internal static let background = Color(asset: Asset.Navigation.background)
      internal static let buttonActive = Color(asset: Asset.Navigation.buttonActive)
      internal static let buttonInactive = Color(asset: Asset.Navigation.buttonInactive)
    }
    
    // MARK: - Shadow
    enum Shadow {
      internal static let primary = Color(asset: Asset.Shadow.primary)
    }
    
    // MARK: - Shape
    enum Shape {
      internal static let primary = Color(asset: Asset.Shape.primary)
      internal static let secondary = Color(asset: Asset.Shape.secondary)
      internal static let tertiary = Color(asset: Asset.Shape.tertiary)
      internal static let transperent = Color(asset: Asset.Shape.transperent)
    }
    
    // MARK: - Text
    enum Text {
      internal static let labelInversion = Color(asset: Asset.Text.labelInversion)
      internal static let primary = Color(asset: Asset.Text.primary)
      internal static let secondary = Color(asset: Asset.Text.secondary)
      internal static let tertiary = Color(asset: Asset.Text.tertiary)
      internal static let white = Color(asset: Asset.Text.white)
    }
    
    // MARK: - Widget
    enum Widget {
      internal static let actionsBackground = Color(asset: Asset.Widget.actionsBackground)
      internal static let bottomPanel = Color(asset: Asset.Widget.bottomPanel)
      internal static let card = Color(asset: Asset.Widget.card)
      internal static let divider = Color(asset: Asset.Widget.divider)
      internal static let inactiveTab = Color(asset: Asset.Widget.inactiveTab)
      internal static let secondary = Color(asset: Asset.Widget.secondary)
    }
}
