import UIKit

struct ColorInfo: Hashable {
    let name: String
    let color: UIColor
}

struct ColorCollectionInfo: Hashable {
    let name: String
    let colors: [ColorInfo]
}

struct ColorAssetInfo: Hashable {
    let name: String
    let collections: [ColorCollectionInfo]
}

extension UIColor {
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
                UIColor.Background.collectionInfo, 
                UIColor.Button.collectionInfo, 
                UIColor.Dashboard.collectionInfo, 
                UIColor.Shadow.collectionInfo, 
                UIColor.Stroke.collectionInfo, 
                UIColor.Text.collectionInfo
            ]
        )
    ]
}

extension UIColor.Dark {
    static let collectionInfo = ColorCollectionInfo(
        name: "Dark",
        colors: [
            ColorInfo(name: "amber", color: UIColor.Dark.amber), 
            ColorInfo(name: "blue", color: UIColor.Dark.blue), 
            ColorInfo(name: "green", color: UIColor.Dark.green), 
            ColorInfo(name: "grey", color: UIColor.Dark.grey), 
            ColorInfo(name: "pink", color: UIColor.Dark.pink), 
            ColorInfo(name: "purple", color: UIColor.Dark.purple), 
            ColorInfo(name: "red", color: UIColor.Dark.red), 
            ColorInfo(name: "sky", color: UIColor.Dark.sky), 
            ColorInfo(name: "teal", color: UIColor.Dark.teal), 
            ColorInfo(name: "yellow", color: UIColor.Dark.yellow)
        ]
    )
}
extension UIColor.Light {
    static let collectionInfo = ColorCollectionInfo(
        name: "Light",
        colors: [
            ColorInfo(name: "amber", color: UIColor.Light.amber), 
            ColorInfo(name: "blue", color: UIColor.Light.blue), 
            ColorInfo(name: "green", color: UIColor.Light.green), 
            ColorInfo(name: "grey", color: UIColor.Light.grey), 
            ColorInfo(name: "pink", color: UIColor.Light.pink), 
            ColorInfo(name: "purple", color: UIColor.Light.purple), 
            ColorInfo(name: "red", color: UIColor.Light.red), 
            ColorInfo(name: "sky", color: UIColor.Light.sky), 
            ColorInfo(name: "teal", color: UIColor.Light.teal), 
            ColorInfo(name: "yellow", color: UIColor.Light.yellow)
        ]
    )
}
extension UIColor.System {
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
extension UIColor.VeryLight {
    static let collectionInfo = ColorCollectionInfo(
        name: "VeryLight",
        colors: [
            ColorInfo(name: "amber", color: UIColor.VeryLight.amber), 
            ColorInfo(name: "blue", color: UIColor.VeryLight.blue), 
            ColorInfo(name: "green", color: UIColor.VeryLight.green), 
            ColorInfo(name: "grey", color: UIColor.VeryLight.grey), 
            ColorInfo(name: "pink", color: UIColor.VeryLight.pink), 
            ColorInfo(name: "purple", color: UIColor.VeryLight.purple), 
            ColorInfo(name: "red", color: UIColor.VeryLight.red), 
            ColorInfo(name: "sky", color: UIColor.VeryLight.sky), 
            ColorInfo(name: "teal", color: UIColor.VeryLight.teal), 
            ColorInfo(name: "yellow", color: UIColor.VeryLight.yellow)
        ]
    )
}

extension UIColor.Additional {
    static let collectionInfo = ColorCollectionInfo(
        name: "Additional",
        colors: [
            ColorInfo(name: "space", color: UIColor.Additional.space)
        ]
    )
}
extension UIColor.Auth {
    static let collectionInfo = ColorCollectionInfo(
        name: "Auth",
        colors: [
            ColorInfo(name: "body", color: UIColor.Auth.body), 
            ColorInfo(name: "caption", color: UIColor.Auth.caption), 
            ColorInfo(name: "dot", color: UIColor.Auth.dot), 
            ColorInfo(name: "dotSelected", color: UIColor.Auth.dotSelected), 
            ColorInfo(name: "input", color: UIColor.Auth.input)
        ]
    )
}
extension UIColor.Background {
    static let collectionInfo = ColorCollectionInfo(
        name: "Background",
        colors: [
            ColorInfo(name: "black", color: UIColor.Background.black), 
            ColorInfo(name: "highlightedOfSelected", color: UIColor.Background.highlightedOfSelected), 
            ColorInfo(name: "material", color: UIColor.Background.material), 
            ColorInfo(name: "primary", color: UIColor.Background.primary), 
            ColorInfo(name: "secondary", color: UIColor.Background.secondary)
        ]
    )
}
extension UIColor.Button {
    static let collectionInfo = ColorCollectionInfo(
        name: "Button",
        colors: [
            ColorInfo(name: "accent", color: UIColor.Button.accent), 
            ColorInfo(name: "active", color: UIColor.Button.active), 
            ColorInfo(name: "button", color: UIColor.Button.button), 
            ColorInfo(name: "inactive", color: UIColor.Button.inactive), 
            ColorInfo(name: "white", color: UIColor.Button.white)
        ]
    )
}
extension UIColor.Dashboard {
    static let collectionInfo = ColorCollectionInfo(
        name: "Dashboard",
        colors: [
            ColorInfo(name: "card", color: UIColor.Dashboard.card)
        ]
    )
}
extension UIColor.Shadow {
    static let collectionInfo = ColorCollectionInfo(
        name: "Shadow",
        colors: [
            ColorInfo(name: "primary", color: UIColor.Shadow.primary)
        ]
    )
}
extension UIColor.Stroke {
    static let collectionInfo = ColorCollectionInfo(
        name: "Stroke",
        colors: [
            ColorInfo(name: "primary", color: UIColor.Stroke.primary), 
            ColorInfo(name: "secondary", color: UIColor.Stroke.secondary), 
            ColorInfo(name: "tertiary", color: UIColor.Stroke.tertiary), 
            ColorInfo(name: "transperent", color: UIColor.Stroke.transperent)
        ]
    )
}
extension UIColor.Text {
    static let collectionInfo = ColorCollectionInfo(
        name: "Text",
        colors: [
            ColorInfo(name: "labelInversion", color: UIColor.Text.labelInversion), 
            ColorInfo(name: "primary", color: UIColor.Text.primary), 
            ColorInfo(name: "secondary", color: UIColor.Text.secondary), 
            ColorInfo(name: "tertiary", color: UIColor.Text.tertiary), 
            ColorInfo(name: "white", color: UIColor.Text.white)
        ]
    )
}

