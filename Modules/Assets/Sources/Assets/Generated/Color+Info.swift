import UIKit

public struct ColorInfo: Hashable, Sendable {
    public let name: String
    public let color: UIColor
}

public struct ColorCollectionInfo: Hashable, Sendable {
    public let name: String
    public let colors: [ColorInfo]
}

public struct ColorAssetInfo: Hashable, Sendable {
    public let name: String
    public let collections: [ColorCollectionInfo]
}

public extension UIColor {
    static let anytypeAssetsInfo: [ColorAssetInfo] = [
        ColorAssetInfo(
            name: "ComponentColors",
            collections: [
                UIColor.Dark.collectionInfo,
                UIColor.Light.collectionInfo,
                UIColor.System.collectionInfo,
                UIColor.VeryLight.collectionInfo
            ]
        ), 
        ColorAssetInfo(
            name: "SystemColors",
            collections: [
                UIColor.Additional.collectionInfo,
                UIColor.Auth.collectionInfo,
                UIColor.BackgroundCustom.collectionInfo,
                UIColor.CoverGradients.collectionInfo,
                UIColor.Gradients.collectionInfo,
                UIColor.Launch.collectionInfo,
                UIColor.ModalScreen.collectionInfo,
                UIColor.Shadow.collectionInfo,
                UIColor.Widget.collectionInfo
        ,
                UIColor.Background.collectionInfo,
                UIColor.Control.collectionInfo,
                UIColor.Shape.collectionInfo,
                UIColor.Text.collectionInfo
            ]
        )
    ]
}

public extension UIColor.Dark {
    static let collectionInfo = ColorCollectionInfo(
        name: "Dark",
        colors: [
            ColorInfo(name: "blue", color: UIColor.Dark.blue),
            ColorInfo(name: "green", color: UIColor.Dark.green),
            ColorInfo(name: "grey", color: UIColor.Dark.grey),
            ColorInfo(name: "orange", color: UIColor.Dark.orange),
            ColorInfo(name: "pink", color: UIColor.Dark.pink),
            ColorInfo(name: "purple", color: UIColor.Dark.purple),
            ColorInfo(name: "red", color: UIColor.Dark.red),
            ColorInfo(name: "sky", color: UIColor.Dark.sky),
            ColorInfo(name: "teal", color: UIColor.Dark.teal),
            ColorInfo(name: "yellow", color: UIColor.Dark.yellow)
        ]
    )
}
public extension UIColor.Light {
    static let collectionInfo = ColorCollectionInfo(
        name: "Light",
        colors: [
            ColorInfo(name: "blue", color: UIColor.Light.blue),
            ColorInfo(name: "green", color: UIColor.Light.green),
            ColorInfo(name: "grey", color: UIColor.Light.grey),
            ColorInfo(name: "orange", color: UIColor.Light.orange),
            ColorInfo(name: "pink", color: UIColor.Light.pink),
            ColorInfo(name: "purple", color: UIColor.Light.purple),
            ColorInfo(name: "red", color: UIColor.Light.red),
            ColorInfo(name: "sky", color: UIColor.Light.sky),
            ColorInfo(name: "teal", color: UIColor.Light.teal),
            ColorInfo(name: "yellow", color: UIColor.Light.yellow)
        ]
    )
}
public extension UIColor.System {
    static let collectionInfo = ColorCollectionInfo(
        name: "System",
        colors: [
            ColorInfo(name: "amber100", color: UIColor.System.amber100),
            ColorInfo(name: "amber125", color: UIColor.System.amber125),
            ColorInfo(name: "amber25", color: UIColor.System.amber25),
            ColorInfo(name: "amber50", color: UIColor.System.amber50),
            ColorInfo(name: "amber80", color: UIColor.System.amber80),
            ColorInfo(name: "blue", color: UIColor.System.blue),
            ColorInfo(name: "green", color: UIColor.System.green),
            ColorInfo(name: "grey", color: UIColor.System.grey),
            ColorInfo(name: "pink", color: UIColor.System.pink),
            ColorInfo(name: "purple", color: UIColor.System.purple),
            ColorInfo(name: "red", color: UIColor.System.red),
            ColorInfo(name: "sky", color: UIColor.System.sky),
            ColorInfo(name: "teal", color: UIColor.System.teal),
            ColorInfo(name: "yellow", color: UIColor.System.yellow)
        ]
    )
}
public extension UIColor.VeryLight {
    static let collectionInfo = ColorCollectionInfo(
        name: "VeryLight",
        colors: [
            ColorInfo(name: "blue", color: UIColor.VeryLight.blue),
            ColorInfo(name: "green", color: UIColor.VeryLight.green),
            ColorInfo(name: "grey", color: UIColor.VeryLight.grey),
            ColorInfo(name: "orange", color: UIColor.VeryLight.orange),
            ColorInfo(name: "pink", color: UIColor.VeryLight.pink),
            ColorInfo(name: "purple", color: UIColor.VeryLight.purple),
            ColorInfo(name: "red", color: UIColor.VeryLight.red),
            ColorInfo(name: "sky", color: UIColor.VeryLight.sky),
            ColorInfo(name: "teal", color: UIColor.VeryLight.teal),
            ColorInfo(name: "yellow", color: UIColor.VeryLight.yellow)
        ]
    )
}

public extension UIColor.Additional {
    static let collectionInfo = ColorCollectionInfo(
        name: "Additional",
        colors: [
            ColorInfo(name: "selected", color: UIColor.Additional.Indicator.selected),
            ColorInfo(name: "unselected", color: UIColor.Additional.Indicator.unselected)
    ,
            ColorInfo(name: "messageInputShadow", color: UIColor.Additional.messageInputShadow),
            ColorInfo(name: "separator", color: UIColor.Additional.separator),
            ColorInfo(name: "space", color: UIColor.Additional.space)
        ]
    )
}
public extension UIColor.Auth {
    static let collectionInfo = ColorCollectionInfo(
        name: "Auth",
        colors: [
            ColorInfo(name: "body", color: UIColor.Auth.body),
            ColorInfo(name: "caption", color: UIColor.Auth.caption),
            ColorInfo(name: "dot", color: UIColor.Auth.dot),
            ColorInfo(name: "dotSelected", color: UIColor.Auth.dotSelected),
            ColorInfo(name: "input", color: UIColor.Auth.input),
            ColorInfo(name: "inputText", color: UIColor.Auth.inputText),
            ColorInfo(name: "modalBackground", color: UIColor.Auth.modalBackground),
            ColorInfo(name: "modalContent", color: UIColor.Auth.modalContent),
            ColorInfo(name: "text", color: UIColor.Auth.text)
        ]
    )
}
public extension UIColor.BackgroundCustom {
    static let collectionInfo = ColorCollectionInfo(
        name: "BackgroundCustom",
        colors: [
            ColorInfo(name: "black", color: UIColor.BackgroundCustom.black),
            ColorInfo(name: "material", color: UIColor.BackgroundCustom.material)
        ]
    )
}
public extension UIColor.CoverGradients {
    static let collectionInfo = ColorCollectionInfo(
        name: "CoverGradients",
        colors: [
            ColorInfo(name: "blueEnd", color: UIColor.CoverGradients.blueEnd),
            ColorInfo(name: "bluePinkEnd", color: UIColor.CoverGradients.bluePinkEnd),
            ColorInfo(name: "bluePinkStart", color: UIColor.CoverGradients.bluePinkStart),
            ColorInfo(name: "blueStart", color: UIColor.CoverGradients.blueStart),
            ColorInfo(name: "greenOrangeEnd", color: UIColor.CoverGradients.greenOrangeEnd),
            ColorInfo(name: "greenOrangeStart", color: UIColor.CoverGradients.greenOrangeStart),
            ColorInfo(name: "pinkOrangeEnd", color: UIColor.CoverGradients.pinkOrangeEnd),
            ColorInfo(name: "pinkOrangeStart", color: UIColor.CoverGradients.pinkOrangeStart),
            ColorInfo(name: "redEnd", color: UIColor.CoverGradients.redEnd),
            ColorInfo(name: "redStart", color: UIColor.CoverGradients.redStart),
            ColorInfo(name: "skyEnd", color: UIColor.CoverGradients.skyEnd),
            ColorInfo(name: "skyStart", color: UIColor.CoverGradients.skyStart),
            ColorInfo(name: "tealEnd", color: UIColor.CoverGradients.tealEnd),
            ColorInfo(name: "tealStart", color: UIColor.CoverGradients.tealStart),
            ColorInfo(name: "yellowEnd", color: UIColor.CoverGradients.yellowEnd),
            ColorInfo(name: "yellowStart", color: UIColor.CoverGradients.yellowStart)
        ]
    )
}
public extension UIColor.Gradients {
    static let collectionInfo = ColorCollectionInfo(
        name: "Gradients",
        colors: [
            ColorInfo(name: "darkBlue", color: UIColor.Gradients.UpdateAlert.darkBlue),
            ColorInfo(name: "green", color: UIColor.Gradients.UpdateAlert.green),
            ColorInfo(name: "lightBlue", color: UIColor.Gradients.UpdateAlert.lightBlue)
    ,
            ColorInfo(name: "fadingBlue", color: UIColor.Gradients.fadingBlue),
            ColorInfo(name: "fadingGreen", color: UIColor.Gradients.fadingGreen),
            ColorInfo(name: "fadingPink", color: UIColor.Gradients.fadingPink),
            ColorInfo(name: "fadingPurple", color: UIColor.Gradients.fadingPurple),
            ColorInfo(name: "fadingRed", color: UIColor.Gradients.fadingRed),
            ColorInfo(name: "fadingSky", color: UIColor.Gradients.fadingSky),
            ColorInfo(name: "fadingTeal", color: UIColor.Gradients.fadingTeal),
            ColorInfo(name: "fadingYellow", color: UIColor.Gradients.fadingYellow),
            ColorInfo(name: "green", color: UIColor.Gradients.green),
            ColorInfo(name: "orange", color: UIColor.Gradients.orange),
            ColorInfo(name: "white", color: UIColor.Gradients.white)
        ]
    )
}
public extension UIColor.Launch {
    static let collectionInfo = ColorCollectionInfo(
        name: "Launch",
        colors: [
            ColorInfo(name: "circle", color: UIColor.Launch.circle)
        ]
    )
}
public extension UIColor.ModalScreen {
    static let collectionInfo = ColorCollectionInfo(
        name: "ModalScreen",
        colors: [
            ColorInfo(name: "background", color: UIColor.ModalScreen.background),
            ColorInfo(name: "backgroundWithBlur", color: UIColor.ModalScreen.backgroundWithBlur)
        ]
    )
}
public extension UIColor.Shadow {
    static let collectionInfo = ColorCollectionInfo(
        name: "Shadow",
        colors: [
            ColorInfo(name: "primary", color: UIColor.Shadow.primary)
        ]
    )
}
public extension UIColor.Widget {
    static let collectionInfo = ColorCollectionInfo(
        name: "Widget",
        colors: [
            ColorInfo(name: "actionsBackground", color: UIColor.Widget.actionsBackground),
            ColorInfo(name: "bottomPanel", color: UIColor.Widget.bottomPanel),
            ColorInfo(name: "divider", color: UIColor.Widget.divider),
            ColorInfo(name: "inactiveTab", color: UIColor.Widget.inactiveTab),
            ColorInfo(name: "secondary", color: UIColor.Widget.secondary)
        ]
    )
}
public extension UIColor.Background {
    static let collectionInfo = ColorCollectionInfo(
        name: "Background",
        colors: [
            ColorInfo(name: "bubbleSomeones", color: UIColor.Background.Chat.bubbleSomeones),
            ColorInfo(name: "bubbleYour", color: UIColor.Background.Chat.bubbleYour),
            ColorInfo(name: "replySomeones", color: UIColor.Background.Chat.replySomeones),
            ColorInfo(name: "replyYours", color: UIColor.Background.Chat.replyYours),
            ColorInfo(name: "whiteTransparent", color: UIColor.Background.Chat.whiteTransparent)
    ,
            ColorInfo(name: "highlightedLight", color: UIColor.Background.highlightedLight),
            ColorInfo(name: "highlightedMedium", color: UIColor.Background.highlightedMedium),
            ColorInfo(name: "navigationPanel", color: UIColor.Background.navigationPanel),
            ColorInfo(name: "primary", color: UIColor.Background.primary),
            ColorInfo(name: "secondary", color: UIColor.Background.secondary),
            ColorInfo(name: "widget", color: UIColor.Background.widget)
        ]
    )
}
public extension UIColor.Control {
    static let collectionInfo = ColorCollectionInfo(
        name: "Control",
        colors: [
            ColorInfo(name: "accent", color: UIColor.Control.accent),
            ColorInfo(name: "active", color: UIColor.Control.active),
            ColorInfo(name: "button", color: UIColor.Control.button),
            ColorInfo(name: "inactive", color: UIColor.Control.inactive),
            ColorInfo(name: "transparentActive", color: UIColor.Control.transparentActive),
            ColorInfo(name: "transparentInactive", color: UIColor.Control.transparentInactive),
            ColorInfo(name: "white", color: UIColor.Control.white)
        ]
    )
}
public extension UIColor.Shape {
    static let collectionInfo = ColorCollectionInfo(
        name: "Shape",
        colors: [
            ColorInfo(name: "primary", color: UIColor.Shape.primary),
            ColorInfo(name: "secondary", color: UIColor.Shape.secondary),
            ColorInfo(name: "tertiary", color: UIColor.Shape.tertiary),
            ColorInfo(name: "transperentPrimary", color: UIColor.Shape.transperentPrimary),
            ColorInfo(name: "transperentSecondary", color: UIColor.Shape.transperentSecondary),
            ColorInfo(name: "transperentTertiary", color: UIColor.Shape.transperentTertiary)
        ]
    )
}
public extension UIColor.Text {
    static let collectionInfo = ColorCollectionInfo(
        name: "Text",
        colors: [
            ColorInfo(name: "inversion", color: UIColor.Text.inversion),
            ColorInfo(name: "primary", color: UIColor.Text.primary),
            ColorInfo(name: "secondary", color: UIColor.Text.secondary),
            ColorInfo(name: "tertiary", color: UIColor.Text.tertiary),
            ColorInfo(name: "white", color: UIColor.Text.white)
        ]
    )
}

