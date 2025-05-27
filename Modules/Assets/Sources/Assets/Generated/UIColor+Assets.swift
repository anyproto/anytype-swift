import UIKit
import SwiftUI

extension UIColor {
    // MARK: - Dark
    public enum Dark {
      public static let blue = UIColor(asset: Asset.Dark.blue)
      public static let green = UIColor(asset: Asset.Dark.green)
      public static let grey = UIColor(asset: Asset.Dark.grey)
      public static let orange = UIColor(asset: Asset.Dark.orange)
      public static let pink = UIColor(asset: Asset.Dark.pink)
      public static let purple = UIColor(asset: Asset.Dark.purple)
      public static let red = UIColor(asset: Asset.Dark.red)
      public static let sky = UIColor(asset: Asset.Dark.sky)
      public static let teal = UIColor(asset: Asset.Dark.teal)
      public static let yellow = UIColor(asset: Asset.Dark.yellow)
    }
    // MARK: - Light
    public enum Light {
      public static let blue = UIColor(asset: Asset.Light.blue)
      public static let green = UIColor(asset: Asset.Light.green)
      public static let grey = UIColor(asset: Asset.Light.grey)
      public static let orange = UIColor(asset: Asset.Light.orange)
      public static let pink = UIColor(asset: Asset.Light.pink)
      public static let purple = UIColor(asset: Asset.Light.purple)
      public static let red = UIColor(asset: Asset.Light.red)
      public static let sky = UIColor(asset: Asset.Light.sky)
      public static let teal = UIColor(asset: Asset.Light.teal)
      public static let yellow = UIColor(asset: Asset.Light.yellow)
    }
    // MARK: - System
    public enum System {
      public static let amber100 = UIColor(asset: Asset.System.amber100)
      public static let amber125 = UIColor(asset: Asset.System.amber125)
      public static let amber25 = UIColor(asset: Asset.System.amber25)
      public static let amber50 = UIColor(asset: Asset.System.amber50)
      public static let amber80 = UIColor(asset: Asset.System.amber80)
      public static let blue = UIColor(asset: Asset.System.blue)
      public static let green = UIColor(asset: Asset.System.green)
      public static let grey = UIColor(asset: Asset.System.grey)
      public static let pink = UIColor(asset: Asset.System.pink)
      public static let purple = UIColor(asset: Asset.System.purple)
      public static let red = UIColor(asset: Asset.System.red)
      public static let sky = UIColor(asset: Asset.System.sky)
      public static let teal = UIColor(asset: Asset.System.teal)
      public static let yellow = UIColor(asset: Asset.System.yellow)
    }
    // MARK: - VeryLight
    public enum VeryLight {
      public static let blue = UIColor(asset: Asset.VeryLight.blue)
      public static let green = UIColor(asset: Asset.VeryLight.green)
      public static let grey = UIColor(asset: Asset.VeryLight.grey)
      public static let orange = UIColor(asset: Asset.VeryLight.orange)
      public static let pink = UIColor(asset: Asset.VeryLight.pink)
      public static let purple = UIColor(asset: Asset.VeryLight.purple)
      public static let red = UIColor(asset: Asset.VeryLight.red)
      public static let sky = UIColor(asset: Asset.VeryLight.sky)
      public static let teal = UIColor(asset: Asset.VeryLight.teal)
      public static let yellow = UIColor(asset: Asset.VeryLight.yellow)
    }
    // MARK: - Custom
    // MARK: - Additional
    public enum Additional {
      // MARK: - Indicator
      public enum Indicator {
        public static let selected = UIColor(asset: Asset.Additional.Indicator.selected)
        public static let unselected = UIColor(asset: Asset.Additional.Indicator.unselected)
      }
      public static let messageInputShadow = UIColor(asset: Asset.Additional.messageInputShadow)
      public static let separator = UIColor(asset: Asset.Additional.separator)
      public static let space = UIColor(asset: Asset.Additional.space)
    }
    // MARK: - Auth
    public enum Auth {
      public static let body = UIColor(asset: Asset.Auth.body)
      public static let caption = UIColor(asset: Asset.Auth.caption)
      public static let dot = UIColor(asset: Asset.Auth.dot)
      public static let dotSelected = UIColor(asset: Asset.Auth.dotSelected)
      public static let input = UIColor(asset: Asset.Auth.input)
      public static let inputText = UIColor(asset: Asset.Auth.inputText)
      public static let modalBackground = UIColor(asset: Asset.Auth.modalBackground)
      public static let modalContent = UIColor(asset: Asset.Auth.modalContent)
      public static let text = UIColor(asset: Asset.Auth.text)
    }
    // MARK: - BackgroundCustom
    public enum BackgroundCustom {
      public static let black = UIColor(asset: Asset.BackgroundCustom.black)
      public static let material = UIColor(asset: Asset.BackgroundCustom.material)
    }
    // MARK: - CoverGradients
    public enum CoverGradients {
      public static let blueEnd = UIColor(asset: Asset.CoverGradients.blueEnd)
      public static let bluePinkEnd = UIColor(asset: Asset.CoverGradients.bluePinkEnd)
      public static let bluePinkStart = UIColor(asset: Asset.CoverGradients.bluePinkStart)
      public static let blueStart = UIColor(asset: Asset.CoverGradients.blueStart)
      public static let greenOrangeEnd = UIColor(asset: Asset.CoverGradients.greenOrangeEnd)
      public static let greenOrangeStart = UIColor(asset: Asset.CoverGradients.greenOrangeStart)
      public static let pinkOrangeEnd = UIColor(asset: Asset.CoverGradients.pinkOrangeEnd)
      public static let pinkOrangeStart = UIColor(asset: Asset.CoverGradients.pinkOrangeStart)
      public static let redEnd = UIColor(asset: Asset.CoverGradients.redEnd)
      public static let redStart = UIColor(asset: Asset.CoverGradients.redStart)
      public static let skyEnd = UIColor(asset: Asset.CoverGradients.skyEnd)
      public static let skyStart = UIColor(asset: Asset.CoverGradients.skyStart)
      public static let tealEnd = UIColor(asset: Asset.CoverGradients.tealEnd)
      public static let tealStart = UIColor(asset: Asset.CoverGradients.tealStart)
      public static let yellowEnd = UIColor(asset: Asset.CoverGradients.yellowEnd)
      public static let yellowStart = UIColor(asset: Asset.CoverGradients.yellowStart)
    }
    // MARK: - Gradients
    public enum Gradients {
      // MARK: - Push
      public enum Push {
        public static let violetEnd = UIColor(asset: Asset.Gradients.Push.violetEnd)
        public static let violetStart = UIColor(asset: Asset.Gradients.Push.violetStart)
      }
      // MARK: - UpdateAlert
      public enum UpdateAlert {
        public static let darkBlue = UIColor(asset: Asset.Gradients.UpdateAlert.darkBlue)
        public static let green = UIColor(asset: Asset.Gradients.UpdateAlert.green)
        public static let lightBlue = UIColor(asset: Asset.Gradients.UpdateAlert.lightBlue)
      }
      public static let fadingBlue = UIColor(asset: Asset.Gradients.fadingBlue)
      public static let fadingGreen = UIColor(asset: Asset.Gradients.fadingGreen)
      public static let fadingIce = UIColor(asset: Asset.Gradients.fadingIce)
      public static let fadingPink = UIColor(asset: Asset.Gradients.fadingPink)
      public static let fadingPurple = UIColor(asset: Asset.Gradients.fadingPurple)
      public static let fadingRed = UIColor(asset: Asset.Gradients.fadingRed)
      public static let fadingSky = UIColor(asset: Asset.Gradients.fadingSky)
      public static let fadingTeal = UIColor(asset: Asset.Gradients.fadingTeal)
      public static let fadingYellow = UIColor(asset: Asset.Gradients.fadingYellow)
      public static let green = UIColor(asset: Asset.Gradients.green)
      public static let orange = UIColor(asset: Asset.Gradients.orange)
      public static let white = UIColor(asset: Asset.Gradients.white)
    }
    // MARK: - Launch
    public enum Launch {
      public static let circle = UIColor(asset: Asset.Launch.circle)
    }
    // MARK: - ModalScreen
    public enum ModalScreen {
      public static let background = UIColor(asset: Asset.ModalScreen.background)
      public static let backgroundWithBlur = UIColor(asset: Asset.ModalScreen.backgroundWithBlur)
    }
    // MARK: - PushNotifications
    public enum PushNotifications {
      public static let background = UIColor(asset: Asset.PushNotifications.background)
      public static let hiddenText = UIColor(asset: Asset.PushNotifications.hiddenText)
      public static let text = UIColor(asset: Asset.PushNotifications.text)
    }
    // MARK: - Shadow
    public enum Shadow {
      public static let primary = UIColor(asset: Asset.Shadow.primary)
    }
    // MARK: - Widget
    public enum Widget {
      public static let actionsBackground = UIColor(asset: Asset.Widget.actionsBackground)
      public static let bottomPanel = UIColor(asset: Asset.Widget.bottomPanel)
      public static let divider = UIColor(asset: Asset.Widget.divider)
      public static let inactiveTab = UIColor(asset: Asset.Widget.inactiveTab)
      public static let secondary = UIColor(asset: Asset.Widget.secondary)
    }
    // MARK: - DesignSystem
    // MARK: - Background
    public enum Background {
      // MARK: - Chat
      public enum Chat {
        public static let bubbleSomeones = UIColor(asset: Asset.Background.Chat.bubbleSomeones)
        public static let bubbleYour = UIColor(asset: Asset.Background.Chat.bubbleYour)
        public static let replySomeones = UIColor(asset: Asset.Background.Chat.replySomeones)
        public static let replyYours = UIColor(asset: Asset.Background.Chat.replyYours)
        public static let whiteTransparent = UIColor(asset: Asset.Background.Chat.whiteTransparent)
      }
      public static let highlightedLight = UIColor(asset: Asset.Background.highlightedLight)
      public static let highlightedMedium = UIColor(asset: Asset.Background.highlightedMedium)
      public static let navigationPanel = UIColor(asset: Asset.Background.navigationPanel)
      public static let primary = UIColor(asset: Asset.Background.primary)
      public static let secondary = UIColor(asset: Asset.Background.secondary)
      public static let widget = UIColor(asset: Asset.Background.widget)
    }
    // MARK: - Control
    public enum Control {
      public static let accent = UIColor(asset: Asset.Control.accent)
      public static let active = UIColor(asset: Asset.Control.active)
      public static let button = UIColor(asset: Asset.Control.button)
      public static let inactive = UIColor(asset: Asset.Control.inactive)
      public static let transparentActive = UIColor(asset: Asset.Control.transparentActive)
      public static let transparentInactive = UIColor(asset: Asset.Control.transparentInactive)
      public static let white = UIColor(asset: Asset.Control.white)
    }
    // MARK: - Shape
    public enum Shape {
      public static let primary = UIColor(asset: Asset.Shape.primary)
      public static let secondary = UIColor(asset: Asset.Shape.secondary)
      public static let tertiary = UIColor(asset: Asset.Shape.tertiary)
      public static let transperentPrimary = UIColor(asset: Asset.Shape.transperentPrimary)
      public static let transperentSecondary = UIColor(asset: Asset.Shape.transperentSecondary)
      public static let transperentTertiary = UIColor(asset: Asset.Shape.transperentTertiary)
    }
    // MARK: - Text
    public enum Text {
      public static let inversion = UIColor(asset: Asset.Text.inversion)
      public static let primary = UIColor(asset: Asset.Text.primary)
      public static let secondary = UIColor(asset: Asset.Text.secondary)
      public static let tertiary = UIColor(asset: Asset.Text.tertiary)
      public static let white = UIColor(asset: Asset.Text.white)
    }
}
