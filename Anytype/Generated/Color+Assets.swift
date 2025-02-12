import UIKit
import SwiftUI

extension Color {
  
    // MARK: - Dark
    enum Dark {
      internal static let blue = Color(asset: Asset.Dark.blue)
      internal static let green = Color(asset: Asset.Dark.green)
      internal static let grey = Color(asset: Asset.Dark.grey)
      internal static let orange = Color(asset: Asset.Dark.orange)
      internal static let pink = Color(asset: Asset.Dark.pink)
      internal static let purple = Color(asset: Asset.Dark.purple)
      internal static let red = Color(asset: Asset.Dark.red)
      internal static let sky = Color(asset: Asset.Dark.sky)
      internal static let teal = Color(asset: Asset.Dark.teal)
      internal static let yellow = Color(asset: Asset.Dark.yellow)
    }
    
    // MARK: - Light
    enum Light {
      internal static let blue = Color(asset: Asset.Light.blue)
      internal static let green = Color(asset: Asset.Light.green)
      internal static let grey = Color(asset: Asset.Light.grey)
      internal static let orange = Color(asset: Asset.Light.orange)
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
      internal static let blue = Color(asset: Asset.VeryLight.blue)
      internal static let green = Color(asset: Asset.VeryLight.green)
      internal static let grey = Color(asset: Asset.VeryLight.grey)
      internal static let orange = Color(asset: Asset.VeryLight.orange)
      internal static let pink = Color(asset: Asset.VeryLight.pink)
      internal static let purple = Color(asset: Asset.VeryLight.purple)
      internal static let red = Color(asset: Asset.VeryLight.red)
      internal static let sky = Color(asset: Asset.VeryLight.sky)
      internal static let teal = Color(asset: Asset.VeryLight.teal)
      internal static let yellow = Color(asset: Asset.VeryLight.yellow)
    }
  
    // MARK: - Custom
    
    // MARK: - Additional
    enum Additional {
      
      // MARK: - Indicator
      enum Indicator {
        internal static let selected = Color(asset: Asset.Additional.Indicator.selected)
        internal static let unselected = Color(asset: Asset.Additional.Indicator.unselected)
      }
      internal static let messageInputShadow = Color(asset: Asset.Additional.messageInputShadow)
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
    
    // MARK: - BackgroundCustom
    enum BackgroundCustom {
      internal static let black = Color(asset: Asset.BackgroundCustom.black)
      internal static let material = Color(asset: Asset.BackgroundCustom.material)
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
    
    // MARK: - CoverGradients
    enum CoverGradients {
      internal static let blueEnd = Color(asset: Asset.CoverGradients.blueEnd)
      internal static let bluePinkEnd = Color(asset: Asset.CoverGradients.bluePinkEnd)
      internal static let bluePinkStart = Color(asset: Asset.CoverGradients.bluePinkStart)
      internal static let blueStart = Color(asset: Asset.CoverGradients.blueStart)
      internal static let greenOrangeEnd = Color(asset: Asset.CoverGradients.greenOrangeEnd)
      internal static let greenOrangeStart = Color(asset: Asset.CoverGradients.greenOrangeStart)
      internal static let pinkOrangeEnd = Color(asset: Asset.CoverGradients.pinkOrangeEnd)
      internal static let pinkOrangeStart = Color(asset: Asset.CoverGradients.pinkOrangeStart)
      internal static let redEnd = Color(asset: Asset.CoverGradients.redEnd)
      internal static let redStart = Color(asset: Asset.CoverGradients.redStart)
      internal static let skyEnd = Color(asset: Asset.CoverGradients.skyEnd)
      internal static let skyStart = Color(asset: Asset.CoverGradients.skyStart)
      internal static let tealEnd = Color(asset: Asset.CoverGradients.tealEnd)
      internal static let tealStart = Color(asset: Asset.CoverGradients.tealStart)
      internal static let yellowEnd = Color(asset: Asset.CoverGradients.yellowEnd)
      internal static let yellowStart = Color(asset: Asset.CoverGradients.yellowStart)
    }
    
    // MARK: - Gradients
    enum Gradients {
      
      // MARK: - UpdateAlert
      enum UpdateAlert {
        internal static let darkBlue = Color(asset: Asset.Gradients.UpdateAlert.darkBlue)
        internal static let green = Color(asset: Asset.Gradients.UpdateAlert.green)
        internal static let lightBlue = Color(asset: Asset.Gradients.UpdateAlert.lightBlue)
      }
      internal static let fadingBlue = Color(asset: Asset.Gradients.fadingBlue)
      internal static let fadingGreen = Color(asset: Asset.Gradients.fadingGreen)
      internal static let fadingPink = Color(asset: Asset.Gradients.fadingPink)
      internal static let fadingPurple = Color(asset: Asset.Gradients.fadingPurple)
      internal static let fadingRed = Color(asset: Asset.Gradients.fadingRed)
      internal static let fadingSky = Color(asset: Asset.Gradients.fadingSky)
      internal static let fadingTeal = Color(asset: Asset.Gradients.fadingTeal)
      internal static let fadingYellow = Color(asset: Asset.Gradients.fadingYellow)
      internal static let green = Color(asset: Asset.Gradients.green)
      internal static let orange = Color(asset: Asset.Gradients.orange)
      internal static let white = Color(asset: Asset.Gradients.white)
    }
    
    // MARK: - Launch
    enum Launch {
      internal static let circle = Color(asset: Asset.Launch.circle)
    }
    
    // MARK: - ModalScreen
    enum ModalScreen {
      internal static let background = Color(asset: Asset.ModalScreen.background)
      internal static let backgroundWithBlur = Color(asset: Asset.ModalScreen.backgroundWithBlur)
    }
    
    // MARK: - Shadow
    enum Shadow {
      internal static let primary = Color(asset: Asset.Shadow.primary)
    }
    
    // MARK: - Widget
    enum Widget {
      internal static let actionsBackground = Color(asset: Asset.Widget.actionsBackground)
      internal static let bottomPanel = Color(asset: Asset.Widget.bottomPanel)
      internal static let divider = Color(asset: Asset.Widget.divider)
      internal static let inactiveTab = Color(asset: Asset.Widget.inactiveTab)
      internal static let secondary = Color(asset: Asset.Widget.secondary)
    }
    
    // MARK: - DesignSystem
    
    // MARK: - Background
    enum Background {
      internal static let highlightedLight = Color(asset: Asset.Background.highlightedLight)
      internal static let highlightedMedium = Color(asset: Asset.Background.highlightedMedium)
      internal static let navigationPanel = Color(asset: Asset.Background.navigationPanel)
      internal static let primary = Color(asset: Asset.Background.primary)
      internal static let secondary = Color(asset: Asset.Background.secondary)
      internal static let widget = Color(asset: Asset.Background.widget)
    }
    
    // MARK: - Control
    enum Control {
      internal static let accent = Color(asset: Asset.Control.accent)
      internal static let active = Color(asset: Asset.Control.active)
      internal static let button = Color(asset: Asset.Control.button)
      internal static let inactive = Color(asset: Asset.Control.inactive)
      internal static let transparentActive = Color(asset: Asset.Control.transparentActive)
      internal static let transparentInactive = Color(asset: Asset.Control.transparentInactive)
      internal static let white = Color(asset: Asset.Control.white)
    }
    
    // MARK: - Shape
    enum Shape {
      internal static let primary = Color(asset: Asset.Shape.primary)
      internal static let secondary = Color(asset: Asset.Shape.secondary)
      internal static let tertiary = Color(asset: Asset.Shape.tertiary)
      internal static let transperentPrimary = Color(asset: Asset.Shape.transperentPrimary)
      internal static let transperentSecondary = Color(asset: Asset.Shape.transperentSecondary)
      internal static let transperentTertiary = Color(asset: Asset.Shape.transperentTertiary)
    }
    
    // MARK: - Text
    enum Text {
      internal static let inversion = Color(asset: Asset.Text.inversion)
      internal static let primary = Color(asset: Asset.Text.primary)
      internal static let secondary = Color(asset: Asset.Text.secondary)
      internal static let tertiary = Color(asset: Asset.Text.tertiary)
      internal static let white = Color(asset: Asset.Text.white)
    }
}
