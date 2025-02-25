import Foundation
import SwiftUI
import Services

struct SpaceIconView: View {
    
    let icon: ObjectIcon.Space
    
    var body: some View {
        switch icon {
        case let .name(name, iconOption):
            ImageCharIconView(text: name.withPlaceholder)
                .background(IconColorStorage.iconColor(iconOption: iconOption).gradient)
                .objectIconCornerRadius()
        case .imageId(let imageId):
            ImageIdIconView(imageId: imageId)
                .objectIconCornerRadius()
        case .localPath(let path):
            LocalIconView(contentsOfFile: path)
                .objectIconCornerRadius()
        }
    }
}
