import Foundation
import Services

struct SpaceTypeSettingsData {
    let icon: ImageAsset
    let typaName: String
}

extension SpaceTypeSettingsData {
    init(spaceType: SpaceType) {
        switch spaceType {
        case .oneToOne:
            icon = .X24.chat
        case .chat, .regular, .tech, .unknown, .UNRECOGNIZED:
            icon = .X24.space
        }
        typaName = spaceType.name
    }
}
