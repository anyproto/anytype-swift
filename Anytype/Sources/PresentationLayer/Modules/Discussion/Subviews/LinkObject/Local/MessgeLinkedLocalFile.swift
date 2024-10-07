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
                MessageLinkLocalImageView(contentsOfFile: fileData.path)
                    .frame(width: 72, height: 72)
                    .id(fileData.path)
            case .file:
                // TODO: Implement
                Text("file")
                    .frame(width: 72, height: 72)
            case .video:
                MessageLinkLocalVideoView(url: URL(fileURLWithPath: fileData.path))
                    .frame(width: 72, height: 72)
                    .id(fileData.path)
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
