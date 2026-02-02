import SwiftUI

public enum CustomIconDataColor: Hashable, Sendable, Equatable, Codable, Identifiable {
    case placeholder
    case selected(CustomIconColor)
    
    public var id: String {
        switch self {
        case .placeholder:
            "placeholder"
        case .selected(let color):
            String(describing: color)
        }
    }
    
    public var iconOption: Int? {
        switch self {
        case .placeholder:
            nil
        case .selected(let color):
            color.iconOption
        }
    }
}

public struct CustomIconData: Hashable, Sendable, Equatable, Codable, Identifiable {
    public let icon: CustomIcon
    public let color: CustomIconDataColor
    public let circular: Bool

    public init(icon: CustomIcon, customColor: CustomIconColor, circular: Bool = false) {
        self.icon = icon
        self.color = .selected(customColor)
        self.circular = circular
    }

    public init(placeholderIcon: CustomIcon, circular: Bool = false) {
        self.icon = placeholderIcon
        self.color = .placeholder
        self.circular = circular
    }

    public init(icon: CustomIcon, color: CustomIconDataColor, circular: Bool) {
        self.icon = icon
        self.color = color
        self.circular = circular
    }

    public var id: String { icon.id + color.id }
}


public extension ObjectIcon {
    static var defaultObjectIcon: ObjectIcon {
        .customIcon(CustomIconData(placeholderIcon: .document))
    }
    
    static var emptyTypeIcon: ObjectIcon {
        .customIcon(CustomIconData(placeholderIcon: .type))
    }
    
    static var emptyBookmarkIcon: ObjectIcon {
        .customIcon(CustomIconData(placeholderIcon: .bookmark))
    }
    
    static var emptyDateIcon: ObjectIcon {
        .customIcon(CustomIconData(placeholderIcon: .calendar))
    }
}
