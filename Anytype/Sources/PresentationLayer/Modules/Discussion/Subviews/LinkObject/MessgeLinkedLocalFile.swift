import SwiftUI
import UIKit

struct MessageLinkedLocalFile: View {
    
    let localFile: DiscussionLocalFile
    let onTapObject: () -> Void
    let onTapRemove: () -> Void
    
    var body: some View {
        content
            .cornerRadius(8, style: .continuous)
            .messageLinkShadow()
            .messageLinkRemoveButton(onTapRemove: onTapRemove)
            .onTapGesture {
                onTapObject()
            }
    }
    
    @ViewBuilder
    private var content: some View {
        if let fileData = localFile.data {
            switch fileData.discussionViewType {
            case .image:
                if let image = UIImage(contentsOfFile: fileData.path) {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 72, height: 72)
                }
            case .file:
                Color.green
                    .frame(width: 72, height: 72)
            case .video:
                Color.orange
                    .frame(width: 72, height: 72)
            }
        } else {
            ZStack {
                DotsView()
                    .frame(width: 40, height: 6)
            }
            .frame(width: 72, height: 72)
            .background(Color.Background.secondary)
        }
    }
}
