import Foundation
import SwiftUI
import Services

struct MessageLinkImageView: View {

    let imageId: String
    let onTapRemove: (() -> Void)?
    
    var body: some View {
        ImageIdIconView(imageId: imageId)
            .frame(width: 72, height: 72)
            .messageLinkStyle()
            .messageLinkRemoveButton(onTapRemove: onTapRemove)
    }
}

extension MessageLinkImageView {
    init(details: ObjectDetails, onTapRemove: ((ObjectDetails) -> Void)? = nil) {
        self = MessageLinkImageView(
            imageId: details.id,
            onTapRemove: onTapRemove.map { c in { c(details) } }
        )
    }
}

