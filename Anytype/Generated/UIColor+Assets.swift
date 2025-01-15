import UIKit
import SwiftUI

extension UIColor {
  
    // MARK: - Dark
    enum Dark {
      internal static let blue = UIColor(asset: Asset.Dark.blue)
      internal static let green = UIColor(asset: Asset.Dark.green)
      internal static let grey = UIColor(asset: Asset.Dark.grey)
      internal static let orange = UIColor(asset: Asset.Dark.orange)
      internal static let pink = UIColor(asset: Asset.Dark.pink)
      internal static let purple = UIColor(asset: Asset.Dark.purple)
      internal static let red = UIColor(asset: Asset.Dark.red)
      internal static let sky = UIColor(asset: Asset.Dark.sky)
      internal static let teal = UIColor(asset: Asset.Dark.teal)
      internal static let yellow = UIColor(asset: Asset.Dark.yellow)
    }
    
    // MARK: - Light
    enum Light {
      internal static let blue = UIColor(asset: Asset.Light.blue)
      internal static let green = UIColor(asset: Asset.Light.green)
      internal static let grey = UIColor(asset: Asset.Light.grey)
      internal static let orange = UIColor(asset: Asset.Light.orange)
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
      internal static let blue = UIColor(asset: Asset.VeryLight.blue)
      internal static let green = UIColor(asset: Asset.VeryLight.green)
      internal static let grey = UIColor(asset: Asset.VeryLight.grey)
      internal static let orange = UIColor(asset: Asset.VeryLight.orange)
      internal static let pink = UIColor(asset: Asset.VeryLight.pink)
      internal static let purple = UIColor(asset: Asset.VeryLight.purple)
      internal static let red = UIColor(asset: Asset.VeryLight.red)
      internal static let sky = UIColor(asset: Asset.VeryLight.sky)
      internal static let teal = UIColor(asset: Asset.VeryLight.teal)
      internal static let yellow = UIColor(asset: Asset.VeryLight.yellow)
    }
  
    // MARK: - Custom
    
    // MARK: - Additional
    enum Additional {
      
      // MARK: - Indicator
      enum Indicator {
        internal static let selected = UIColor(asset: Asset.Additional.Indicator.selected)
        internal static let unselected = UIColor(asset: Asset.Additional.Indicator.unselected)
      }
      internal static let messageInputShadow = UIColor(asset: Asset.Additional.messageInputShadow)
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
    
    // MARK: - BackgroundCustom
    enum BackgroundCustom {
      internal static let black = UIColor(asset: Asset.BackgroundCustom.black)
      internal static let material = UIColor(asset: Asset.BackgroundCustom.material)
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
    
    // MARK: - CoverGradients
    enum CoverGradients {
      internal static let blueEnd = UIColor(asset: Asset.CoverGradients.blueEnd)
      internal static let bluePinkEnd = UIColor(asset: Asset.CoverGradients.bluePinkEnd)
      internal static let bluePinkStart = UIColor(asset: Asset.CoverGradients.bluePinkStart)
      internal static let blueStart = UIColor(asset: Asset.CoverGradients.blueStart)
      internal static let greenOrangeEnd = UIColor(asset: Asset.CoverGradients.greenOrangeEnd)
      internal static let greenOrangeStart = UIColor(asset: Asset.CoverGradients.greenOrangeStart)
      internal static let pinkOrangeEnd = UIColor(asset: Asset.CoverGradients.pinkOrangeEnd)
      internal static let pinkOrangeStart = UIColor(asset: Asset.CoverGradients.pinkOrangeStart)
      internal static let redEnd = UIColor(asset: Asset.CoverGradients.redEnd)
      internal static let redStart = UIColor(asset: Asset.CoverGradients.redStart)
      internal static let skyEnd = UIColor(asset: Asset.CoverGradients.skyEnd)
      internal static let skyStart = UIColor(asset: Asset.CoverGradients.skyStart)
      internal static let tealEnd = UIColor(asset: Asset.CoverGradients.tealEnd)
      internal static let tealStart = UIColor(asset: Asset.CoverGradients.tealStart)
      internal static let yellowEnd = UIColor(asset: Asset.CoverGradients.yellowEnd)
      internal static let yellowStart = UIColor(asset: Asset.CoverGradients.yellowStart)
    }
    
    // MARK: - Gradients
    enum Gradients {
      
      // MARK: - UpdateAlert
      enum UpdateAlert {
        internal static let darkBlue = UIColor(asset: Asset.Gradients.UpdateAlert.darkBlue)
        internal static let green = UIColor(asset: Asset.Gradients.UpdateAlert.green)
        internal static let lightBlue = UIColor(asset: Asset.Gradients.UpdateAlert.lightBlue)
      }
      internal static let fadingBlue = UIColor(asset: Asset.Gradients.fadingBlue)
      internal static let fadingGreen = UIColor(asset: Asset.Gradients.fadingGreen)
      internal static let fadingPink = UIColor(asset: Asset.Gradients.fadingPink)
      internal static let fadingPurple = UIColor(asset: Asset.Gradients.fadingPurple)
      internal static let fadingRed = UIColor(asset: Asset.Gradients.fadingRed)
      internal static let fadingSky = UIColor(asset: Asset.Gradients.fadingSky)
      internal static let fadingTeal = UIColor(asset: Asset.Gradients.fadingTeal)
      internal static let fadingYellow = UIColor(asset: Asset.Gradients.fadingYellow)
      internal static let green = UIColor(asset: Asset.Gradients.green)
      internal static let orange = UIColor(asset: Asset.Gradients.orange)
      internal static let white = UIColor(asset: Asset.Gradients.white)
    }
    
    // MARK: - Launch
    enum Launch {
      internal static let circle = UIColor(asset: Asset.Launch.circle)
    }
    
    // MARK: - ModalScreen
    enum ModalScreen {
      internal static let background = UIColor(asset: Asset.ModalScreen.background)
      internal static let backgroundWithBlur = UIColor(asset: Asset.ModalScreen.backgroundWithBlur)
    }
    
    // MARK: - Shadow
    enum Shadow {
      internal static let primary = UIColor(asset: Asset.Shadow.primary)
    }
    
    // MARK: - Widget
    enum Widget {
      internal static let actionsBackground = UIColor(asset: Asset.Widget.actionsBackground)
      internal static let bottomPanel = UIColor(asset: Asset.Widget.bottomPanel)
      internal static let divider = UIColor(asset: Asset.Widget.divider)
      internal static let inactiveTab = UIColor(asset: Asset.Widget.inactiveTab)
      internal static let secondary = UIColor(asset: Asset.Widget.secondary)
    }
    
    // MARK: - DesignSystem
    
    // MARK: - Background
    enum Background {
      internal static let highlightedLight = UIColor(asset: Asset.Background.highlightedLight)
      internal static let highlightedMedium = UIColor(asset: Asset.Background.highlightedMedium)
      internal static let navigationPanel = UIColor(asset: Asset.Background.navigationPanel)
      internal static let primary = UIColor(asset: Asset.Background.primary)
      internal static let secondary = UIColor(asset: Asset.Background.secondary)
      internal static let widget = UIColor(asset: Asset.Background.widget)
    }
    
    // MARK: - Control
    enum Control {
      internal static let accent = UIColor(asset: Asset.Control.accent)
      internal static let active = UIColor(asset: Asset.Control.active)
      internal static let button = UIColor(asset: Asset.Control.button)
      internal static let inactive = UIColor(asset: Asset.Control.inactive)
      internal static let transparentActive = UIColor(asset: Asset.Control.transparentActive)
      internal static let transparentInactive = UIColor(asset: Asset.Control.transparentInactive)
      internal static let white = UIColor(asset: Asset.Control.white)
    }
    
    // MARK: - Shape
    enum Shape {
      internal static let primary = UIColor(asset: Asset.Shape.primary)
      internal static let secondary = UIColor(asset: Asset.Shape.secondary)
      internal static let tertiary = UIColor(asset: Asset.Shape.tertiary)
      internal static let transperentPrimary = UIColor(asset: Asset.Shape.transperentPrimary)
      internal static let transperentSecondary = UIColor(asset: Asset.Shape.transperentSecondary)
      internal static let transperentTertiary = UIColor(asset: Asset.Shape.transperentTertiary)
    }
    
    // MARK: - Text
    enum Text {
      internal static let inversion = UIColor(asset: Asset.Text.inversion)
      internal static let primary = UIColor(asset: Asset.Text.primary)
      internal static let secondary = UIColor(asset: Asset.Text.secondary)
      internal static let tertiary = UIColor(asset: Asset.Text.tertiary)
      internal static let white = UIColor(asset: Asset.Text.white)
    }
}
