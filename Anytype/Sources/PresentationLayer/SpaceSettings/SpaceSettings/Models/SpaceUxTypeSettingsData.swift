import Foundation
import Services

struct SpaceUxTypeSettingsData {
    let icon: ImageAsset
    let typaName: String
}

extension SpaceUxTypeSettingsData {
    init(uxType: SpaceUxType) {
        if uxType.isChat {
            icon = .X24.chat
        } else {
            icon = .X24.space
        }
        typaName = uxType.name
    }
}
