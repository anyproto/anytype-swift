import SwiftUI

public enum CustomIconDataColor: Hashable, Sendable, Equatable, Codable {
    case placeholder
    case selected(CustomIconColor)
    
    public var iconOption: Int? {
        switch self {
        case .placeholder:
            nil
        case .selected(let color):
            color.iconOption
        }
    }
}

public struct CustomIconData: Hashable, Sendable, Equatable, Codable {
    public let icon: CustomIcon
    public let color: CustomIconDataColor
    
    public init(icon: CustomIcon, customColor: CustomIconColor) {
        self.icon = icon
        self.color = .selected(customColor)
    }
    
    public init(placeholderIcon: CustomIcon) {
        self.icon = placeholderIcon
        self.color = .placeholder
    }
}


public extension ObjectIcon {
    static var defaultObjectIcon: ObjectIcon {
        .customIcon(CustomIconData(placeholderIcon: .document))
    }
    
    static var emptyTypeIcon: ObjectIcon {
        .customIcon(CustomIconData(placeholderIcon: .extensionPuzzle))
    }
}

