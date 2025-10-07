import Foundation
import SwiftUI
import Services

struct SpaceIconView: View {
    
    let icon: ObjectIcon.Space
    
    var body: some View {
        switch icon {
        case let .name(name, iconOption, circular):
            nameIcon(name: name, iconOption: iconOption)
                .if(circular, if: {
                    $0.circleOverCornerRadius()
                }, else: {
                    $0.objectIconCornerRadius()
                })
        case let .imageId(imageId, name, iconOption, circular):
            ImageIdIconView(imageId: imageId) {
                nameIcon(name: name, iconOption: iconOption)
            }
            .if(circular, if: {
                $0.circleOverCornerRadius()
            }, else: {
                $0.objectIconCornerRadius()
            })
        case let .localPath(path, circular):
            LocalIconView(contentsOfFile: path)
                .if(circular, if: {
                    $0.circleOverCornerRadius()
                }, else: {
                    $0.objectIconCornerRadius()
                })
        }
    }
    
    private func nameIcon(name: String, iconOption: Int) -> some View {
        ImageCharIconView(
            text: name.withPlaceholder,
            textColor: IconColorStorage.iconTextColor(iconOption: iconOption)
        ) 
        .background(IconColorStorage.iconBackgroundColor(iconOption: iconOption))
    }
}
