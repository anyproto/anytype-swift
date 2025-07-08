import UIKit
import SwiftUI

extension Color {
    // MARK: - Dark
    public enum Dark {
      public static let blue = Color(asset: Asset.Dark.blue)
      public static let green = Color(asset: Asset.Dark.green)
      public static let grey = Color(asset: Asset.Dark.grey)
      public static let orange = Color(asset: Asset.Dark.orange)
      public static let pink = Color(asset: Asset.Dark.pink)
      public static let purple = Color(asset: Asset.Dark.purple)
      public static let red = Color(asset: Asset.Dark.red)
      public static let sky = Color(asset: Asset.Dark.sky)
      public static let teal = Color(asset: Asset.Dark.teal)
      public static let yellow = Color(asset: Asset.Dark.yellow)
    }
    // MARK: - Light
    public enum Light {
      public static let blue = Color(asset: Asset.Light.blue)
      public static let green = Color(asset: Asset.Light.green)
      public static let grey = Color(asset: Asset.Light.grey)
      public static let orange = Color(asset: Asset.Light.orange)
      public static let pink = Color(asset: Asset.Light.pink)
      public static let purple = Color(asset: Asset.Light.purple)
      public static let red = Color(asset: Asset.Light.red)
      public static let sky = Color(asset: Asset.Light.sky)
      public static let teal = Color(asset: Asset.Light.teal)
      public static let yellow = Color(asset: Asset.Light.yellow)
    }
    // MARK: - Pure
    public enum Pure {
      public static let blue = Color(asset: Asset.Pure.blue)
      public static let green = Color(asset: Asset.Pure.green)
      public static let grey = Color(asset: Asset.Pure.grey)
      public static let orange = Color(asset: Asset.Pure.orange)
      public static let pink = Color(asset: Asset.Pure.pink)
      public static let purple = Color(asset: Asset.Pure.purple)
      public static let red = Color(asset: Asset.Pure.red)
      public static let sky = Color(asset: Asset.Pure.sky)
      public static let teal = Color(asset: Asset.Pure.teal)
      public static let yellow = Color(asset: Asset.Pure.yellow)
    }
    // MARK: - VeryLight
    public enum VeryLight {
      public static let blue = Color(asset: Asset.VeryLight.blue)
      public static let green = Color(asset: Asset.VeryLight.green)
      public static let grey = Color(asset: Asset.VeryLight.grey)
      public static let orange = Color(asset: Asset.VeryLight.orange)
      public static let pink = Color(asset: Asset.VeryLight.pink)
      public static let purple = Color(asset: Asset.VeryLight.purple)
      public static let red = Color(asset: Asset.VeryLight.red)
      public static let sky = Color(asset: Asset.VeryLight.sky)
      public static let teal = Color(asset: Asset.VeryLight.teal)
      public static let yellow = Color(asset: Asset.VeryLight.yellow)
    }
    // MARK: - Custom
    // MARK: - Additional
    public enum Additional {
      // MARK: - Indicator
      public enum Indicator {
        public static let selected = Color(asset: Asset.Additional.Indicator.selected)
        public static let unselected = Color(asset: Asset.Additional.Indicator.unselected)
      }
      public static let messageInputShadow = Color(asset: Asset.Additional.messageInputShadow)
      public static let separator = Color(asset: Asset.Additional.separator)
      public static let space = Color(asset: Asset.Additional.space)
    }
    // MARK: - Auth
    public enum Auth {
      public static let body = Color(asset: Asset.Auth.body)
      public static let caption = Color(asset: Asset.Auth.caption)
      public static let dot = Color(asset: Asset.Auth.dot)
      public static let dotSelected = Color(asset: Asset.Auth.dotSelected)
      public static let input = Color(asset: Asset.Auth.input)
      public static let inputText = Color(asset: Asset.Auth.inputText)
      public static let modalBackground = Color(asset: Asset.Auth.modalBackground)
      public static let modalContent = Color(asset: Asset.Auth.modalContent)
      public static let text = Color(asset: Asset.Auth.text)
    }
    // MARK: - BackgroundCustom
    public enum BackgroundCustom {
      public static let black = Color(asset: Asset.BackgroundCustom.black)
      public static let material = Color(asset: Asset.BackgroundCustom.material)
    }
    // MARK: - CoverGradients
    public enum CoverGradients {
      public static let blueEnd = Color(asset: Asset.CoverGradients.blueEnd)
      public static let bluePinkEnd = Color(asset: Asset.CoverGradients.bluePinkEnd)
      public static let bluePinkStart = Color(asset: Asset.CoverGradients.bluePinkStart)
      public static let blueStart = Color(asset: Asset.CoverGradients.blueStart)
      public static let greenOrangeEnd = Color(asset: Asset.CoverGradients.greenOrangeEnd)
      public static let greenOrangeStart = Color(asset: Asset.CoverGradients.greenOrangeStart)
      public static let pinkOrangeEnd = Color(asset: Asset.CoverGradients.pinkOrangeEnd)
      public static let pinkOrangeStart = Color(asset: Asset.CoverGradients.pinkOrangeStart)
      public static let redEnd = Color(asset: Asset.CoverGradients.redEnd)
      public static let redStart = Color(asset: Asset.CoverGradients.redStart)
      public static let skyEnd = Color(asset: Asset.CoverGradients.skyEnd)
      public static let skyStart = Color(asset: Asset.CoverGradients.skyStart)
      public static let tealEnd = Color(asset: Asset.CoverGradients.tealEnd)
      public static let tealStart = Color(asset: Asset.CoverGradients.tealStart)
      public static let yellowEnd = Color(asset: Asset.CoverGradients.yellowEnd)
      public static let yellowStart = Color(asset: Asset.CoverGradients.yellowStart)
    }
    // MARK: - Gradients
    public enum Gradients {
      // MARK: - HeaderAlert
      public enum HeaderAlert {
        public static let redEnd = Color(asset: Asset.Gradients.HeaderAlert.redEnd)
        public static let redStart = Color(asset: Asset.Gradients.HeaderAlert.redStart)
        public static let violetEnd = Color(asset: Asset.Gradients.HeaderAlert.violetEnd)
        public static let violetStart = Color(asset: Asset.Gradients.HeaderAlert.violetStart)
      }
      // MARK: - UpdateAlert
      public enum UpdateAlert {
        public static let darkBlue = Color(asset: Asset.Gradients.UpdateAlert.darkBlue)
        public static let green = Color(asset: Asset.Gradients.UpdateAlert.green)
        public static let lightBlue = Color(asset: Asset.Gradients.UpdateAlert.lightBlue)
      }
      public static let fadingBlue = Color(asset: Asset.Gradients.fadingBlue)
      public static let fadingGreen = Color(asset: Asset.Gradients.fadingGreen)
      public static let fadingIce = Color(asset: Asset.Gradients.fadingIce)
      public static let fadingPink = Color(asset: Asset.Gradients.fadingPink)
      public static let fadingPurple = Color(asset: Asset.Gradients.fadingPurple)
      public static let fadingRed = Color(asset: Asset.Gradients.fadingRed)
      public static let fadingSky = Color(asset: Asset.Gradients.fadingSky)
      public static let fadingTeal = Color(asset: Asset.Gradients.fadingTeal)
      public static let fadingYellow = Color(asset: Asset.Gradients.fadingYellow)
      public static let green = Color(asset: Asset.Gradients.green)
      public static let orange = Color(asset: Asset.Gradients.orange)
      public static let white = Color(asset: Asset.Gradients.white)
    }
    // MARK: - Launch
    public enum Launch {
      public static let circle = Color(asset: Asset.Launch.circle)
    }
    // MARK: - ModalScreen
    public enum ModalScreen {
      public static let background = Color(asset: Asset.ModalScreen.background)
      public static let backgroundWithBlur = Color(asset: Asset.ModalScreen.backgroundWithBlur)
    }
    // MARK: - PushNotifications
    public enum PushNotifications {
      public static let background = Color(asset: Asset.PushNotifications.background)
      public static let hiddenText = Color(asset: Asset.PushNotifications.hiddenText)
      public static let text = Color(asset: Asset.PushNotifications.text)
    }
    // MARK: - Shadow
    public enum Shadow {
      public static let primary = Color(asset: Asset.Shadow.primary)
    }
    // MARK: - Widget
    public enum Widget {
      public static let actionsBackground = Color(asset: Asset.Widget.actionsBackground)
      public static let bottomPanel = Color(asset: Asset.Widget.bottomPanel)
      public static let divider = Color(asset: Asset.Widget.divider)
      public static let inactiveTab = Color(asset: Asset.Widget.inactiveTab)
      public static let secondary = Color(asset: Asset.Widget.secondary)
    }
    // MARK: - DesignSystem
    // MARK: - Background
    public enum Background {
      // MARK: - Chat
      public enum Chat {
        public static let bubbleFlash = Color(asset: Asset.Background.Chat.bubbleFlash)
        public static let bubbleSomeones = Color(asset: Asset.Background.Chat.bubbleSomeones)
        public static let bubbleYour = Color(asset: Asset.Background.Chat.bubbleYour)
        public static let replySomeones = Color(asset: Asset.Background.Chat.replySomeones)
        public static let replyYours = Color(asset: Asset.Background.Chat.replyYours)
        public static let whiteTransparent = Color(asset: Asset.Background.Chat.whiteTransparent)
      }
      public static let highlightedLight = Color(asset: Asset.Background.highlightedLight)
      public static let highlightedMedium = Color(asset: Asset.Background.highlightedMedium)
      public static let navigationPanel = Color(asset: Asset.Background.navigationPanel)
      public static let primary = Color(asset: Asset.Background.primary)
      public static let secondary = Color(asset: Asset.Background.secondary)
      public static let widget = Color(asset: Asset.Background.widget)
    }
    // MARK: - Control
    public enum Control {
      public static let accent100 = Color(asset: Asset.Control.accent100)
      public static let accent125 = Color(asset: Asset.Control.accent125)
      public static let accent25 = Color(asset: Asset.Control.accent25)
      public static let accent50 = Color(asset: Asset.Control.accent50)
      public static let accent80 = Color(asset: Asset.Control.accent80)
      public static let active = Color(asset: Asset.Control.active)
      public static let button = Color(asset: Asset.Control.button)
      public static let inactive = Color(asset: Asset.Control.inactive)
      public static let transparentActive = Color(asset: Asset.Control.transparentActive)
      public static let transparentInactive = Color(asset: Asset.Control.transparentInactive)
      public static let white = Color(asset: Asset.Control.white)
    }
    // MARK: - Shape
    public enum Shape {
      public static let primary = Color(asset: Asset.Shape.primary)
      public static let secondary = Color(asset: Asset.Shape.secondary)
      public static let tertiary = Color(asset: Asset.Shape.tertiary)
      public static let transperentPrimary = Color(asset: Asset.Shape.transperentPrimary)
      public static let transperentSecondary = Color(asset: Asset.Shape.transperentSecondary)
      public static let transperentTertiary = Color(asset: Asset.Shape.transperentTertiary)
    }
    // MARK: - Text
    public enum Text {
      public static let inversion = Color(asset: Asset.Text.inversion)
      public static let primary = Color(asset: Asset.Text.primary)
      public static let secondary = Color(asset: Asset.Text.secondary)
      public static let tertiary = Color(asset: Asset.Text.tertiary)
      public static let white = Color(asset: Asset.Text.white)
    }
}
