import Foundation
import Services

struct SpaceUxTypeSettingsData {
    let icon: ImageAsset
    let typaName: String
}

extension SpaceUxTypeSettingsData {
    init(uxType: SpaceUxType) {
        switch uxType {
        case .chat, .oneToOne:
            icon = .X24.chat
        case .data, .stream, .none, .UNRECOGNIZED:
            icon = .X24.space
        }
        typaName = uxType.name
    }
}
