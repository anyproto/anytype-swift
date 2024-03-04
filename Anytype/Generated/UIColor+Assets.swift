import UIKit
import SwiftUI

extension UIColor {
  
    // MARK: - Dark
    enum Dark {
      internal static let amber = UIColor(asset: Asset.Dark.amber)
      internal static let blue = UIColor(asset: Asset.Dark.blue)
      internal static let green = UIColor(asset: Asset.Dark.green)
      internal static let grey = UIColor(asset: Asset.Dark.grey)
      internal static let pink = UIColor(asset: Asset.Dark.pink)
      internal static let purple = UIColor(asset: Asset.Dark.purple)
      internal static let red = UIColor(asset: Asset.Dark.red)
      internal static let sky = UIColor(asset: Asset.Dark.sky)
      internal static let teal = UIColor(asset: Asset.Dark.teal)
      internal static let yellow = UIColor(asset: Asset.Dark.yellow)
    }
    
    // MARK: - Light
    enum Light {
      internal static let amber = UIColor(asset: Asset.Light.amber)
      internal static let blue = UIColor(asset: Asset.Light.blue)
      internal static let green = UIColor(asset: Asset.Light.green)
      internal static let grey = UIColor(asset: Asset.Light.grey)
      internal static let pink = UIColor(asset: Asset.Light.pink)
      internal static let purple = UIColor(asset: Asset.Light.purple)
      internal static let red = UIColor(asset: Asset.Light.red)
      internal static let sky = UIColor(asset: Asset.Light.sky)
      internal static let teal = UIColor(asset: Asset.Light.teal)
      internal static let yellow = UIColor(asset: Asset.Light.yellow)
    }
    
    // MARK: - System
    enum System {
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
    
    // MARK: - VeryLight
    enum VeryLight {
      internal static let amber = UIColor(asset: Asset.VeryLight.amber)
      internal static let blue = UIColor(asset: Asset.VeryLight.blue)
      internal static let green = UIColor(asset: Asset.VeryLight.green)
      internal static let grey = UIColor(asset: Asset.VeryLight.grey)
      internal static let pink = UIColor(asset: Asset.VeryLight.pink)
      internal static let purple = UIColor(asset: Asset.VeryLight.purple)
      internal static let red = UIColor(asset: Asset.VeryLight.red)
      internal static let sky = UIColor(asset: Asset.VeryLight.sky)
      internal static let teal = UIColor(asset: Asset.VeryLight.teal)
      internal static let yellow = UIColor(asset: Asset.VeryLight.yellow)
    }
  
    // MARK: - Additional
    enum Additional {
      
      // MARK: - Indicator
      enum Indicator {
        internal static let selected = UIColor(asset: Asset.Additional.Indicator.selected)
        internal static let unselected = UIColor(asset: Asset.Additional.Indicator.unselected)
      }
      internal static let gradient = UIColor(asset: Asset.Additional.gradient)
      internal static let separator = UIColor(asset: Asset.Additional.separator)
      internal static let space = UIColor(asset: Asset.Additional.space)
    }
    
    // MARK: - Auth
    enum Auth {
      internal static let body = UIColor(asset: Asset.Auth.body)
      internal static let caption = UIColor(asset: Asset.Auth.caption)
      internal static let dot = UIColor(asset: Asset.Auth.dot)
      internal static let dotSelected = UIColor(asset: Asset.Auth.dotSelected)
      internal static let input = UIColor(asset: Asset.Auth.input)
      internal static let inputText = UIColor(asset: Asset.Auth.inputText)
      internal static let modalBackground = UIColor(asset: Asset.Auth.modalBackground)
      internal static let modalContent = UIColor(asset: Asset.Auth.modalContent)
      internal static let text = UIColor(asset: Asset.Auth.text)
    }
    
    // MARK: - Background
    enum Background {
      internal static let black = UIColor(asset: Asset.Background.black)
      internal static let highlightedOfSelected = UIColor(asset: Asset.Background.highlightedOfSelected)
      internal static let material = UIColor(asset: Asset.Background.material)
      internal static let primary = UIColor(asset: Asset.Background.primary)
      internal static let secondary = UIColor(asset: Asset.Background.secondary)
    }
    
    // MARK: - BottomAlert
    enum BottomAlert {
      internal static let blueEnd = UIColor(asset: Asset.BottomAlert.blueEnd)
      internal static let blueStart = UIColor(asset: Asset.BottomAlert.blueStart)
      internal static let greenEnd = UIColor(asset: Asset.BottomAlert.greenEnd)
      internal static let greenStart = UIColor(asset: Asset.BottomAlert.greenStart)
      internal static let redEnd = UIColor(asset: Asset.BottomAlert.redEnd)
      internal static let redStart = UIColor(asset: Asset.BottomAlert.redStart)
    }
    
    // MARK: - Button
    enum Button {
      internal static let accent = UIColor(asset: Asset.Button.accent)
      internal static let active = UIColor(asset: Asset.Button.active)
      internal static let button = UIColor(asset: Asset.Button.button)
      internal static let inactive = UIColor(asset: Asset.Button.inactive)
      internal static let white = UIColor(asset: Asset.Button.white)
    }
    
    // MARK: - Gradients
    enum Gradients {
      internal static let blueEnd = UIColor(asset: Asset.Gradients.blueEnd)
      internal static let bluePinkEnd = UIColor(asset: Asset.Gradients.bluePinkEnd)
      internal static let bluePinkStart = UIColor(asset: Asset.Gradients.bluePinkStart)
      internal static let blueStart = UIColor(asset: Asset.Gradients.blueStart)
      internal static let fadingGreen = UIColor(asset: Asset.Gradients.fadingGreen)
      internal static let fadingPink = UIColor(asset: Asset.Gradients.fadingPink)
      internal static let fadingPurple = UIColor(asset: Asset.Gradients.fadingPurple)
      internal static let fadingYellow = UIColor(asset: Asset.Gradients.fadingYellow)
      internal static let greenOrangeEnd = UIColor(asset: Asset.Gradients.greenOrangeEnd)
      internal static let greenOrangeStart = UIColor(asset: Asset.Gradients.greenOrangeStart)
      internal static let pinkOrangeEnd = UIColor(asset: Asset.Gradients.pinkOrangeEnd)
      internal static let pinkOrangeStart = UIColor(asset: Asset.Gradients.pinkOrangeStart)
      internal static let redEnd = UIColor(asset: Asset.Gradients.redEnd)
      internal static let redStart = UIColor(asset: Asset.Gradients.redStart)
      internal static let skyEnd = UIColor(asset: Asset.Gradients.skyEnd)
      internal static let skyStart = UIColor(asset: Asset.Gradients.skyStart)
      internal static let tealEnd = UIColor(asset: Asset.Gradients.tealEnd)
      internal static let tealStart = UIColor(asset: Asset.Gradients.tealStart)
      internal static let yellowEnd = UIColor(asset: Asset.Gradients.yellowEnd)
      internal static let yellowStart = UIColor(asset: Asset.Gradients.yellowStart)
    }
    
    // MARK: - ModalScreen
    enum ModalScreen {
      internal static let background = UIColor(asset: Asset.ModalScreen.background)
      internal static let backgroundWithBlur = UIColor(asset: Asset.ModalScreen.backgroundWithBlur)
    }
    
    // MARK: - Navigation
    enum Navigation {
      internal static let background = UIColor(asset: Asset.Navigation.background)
      internal static let buttonActive = UIColor(asset: Asset.Navigation.buttonActive)
      internal static let buttonInactive = UIColor(asset: Asset.Navigation.buttonInactive)
    }
    
    // MARK: - Shadow
    enum Shadow {
      internal static let primary = UIColor(asset: Asset.Shadow.primary)
    }
    
    // MARK: - Shape
    enum Shape {
      internal static let primary = UIColor(asset: Asset.Shape.primary)
      internal static let secondary = UIColor(asset: Asset.Shape.secondary)
      internal static let tertiary = UIColor(asset: Asset.Shape.tertiary)
      internal static let transperent = UIColor(asset: Asset.Shape.transperent)
    }
    
    // MARK: - Text
    enum Text {
      internal static let labelInversion = UIColor(asset: Asset.Text.labelInversion)
      internal static let primary = UIColor(asset: Asset.Text.primary)
      internal static let secondary = UIColor(asset: Asset.Text.secondary)
      internal static let tertiary = UIColor(asset: Asset.Text.tertiary)
      internal static let white = UIColor(asset: Asset.Text.white)
    }
    
    // MARK: - Widget
    enum Widget {
      internal static let actionsBackground = UIColor(asset: Asset.Widget.actionsBackground)
      internal static let bottomPanel = UIColor(asset: Asset.Widget.bottomPanel)
      internal static let card = UIColor(asset: Asset.Widget.card)
      internal static let divider = UIColor(asset: Asset.Widget.divider)
      internal static let inactiveTab = UIColor(asset: Asset.Widget.inactiveTab)
      internal static let secondary = UIColor(asset: Asset.Widget.secondary)
    }
}
