import Foundation
import SwiftUI
import Services

struct SpaceIconView: View {
    
    let icon: ObjectIcon.Space
    
    var body: some View {
        switch icon {
        case let .name(name, iconOption):
            nameIcon(name: name, iconOption: iconOption)
                .objectIconCornerRadius()
        case let .imageId(imageId, name, iconOption):
            ImageIdIconView(imageId: imageId) {
                nameIcon(name: name, iconOption: iconOption)
            }
            .objectIconCornerRadius()
        case .localPath(let path):
            LocalIconView(contentsOfFile: path)
                .objectIconCornerRadius()
        }
    }
    
    private func nameIcon(name: String, iconOption: Int) -> some View {
        ImageCharIconView(text: name.withPlaceholder)
            .background(IconColorStorage.iconColor(iconOption: iconOption).gradient)
    }
}
