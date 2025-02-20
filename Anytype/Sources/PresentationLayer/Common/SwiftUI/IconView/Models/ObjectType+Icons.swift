import Services

extension ObjectType {
    var iconView: IconView { IconView(icon: icon) }
    
    var icon: Icon {
        switch typeIcon {
        case let .customIcon(icon, color):
            .object(.customIcon(icon, color))
        case let .emoji(emoji):
            .object(.emoji(emoji))
        case .none:
            .object(.empty(.objectType))
        }
    }
}


