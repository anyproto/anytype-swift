import SwiftUI
import UIKit

struct MessageLinkedLocalFile: View {
    
    let localFile: DiscussionLocalFile
    let onTapObject: () -> Void
    let onTapRemove: () -> Void
    
    var body: some View {
        content
            .onTapGesture {
                onTapObject()
            }
    }
    
    @ViewBuilder
    private var content: some View {
        if let fileData = localFile.data {
            switch fileData.discussionViewType {
            case .image:
                MessageLinkLocalImageView(contentsOfFile: fileData.path, onTapRemove: onTapRemove)
                    .id(fileData.path)
            case .file:
                // TODO: Implement
                Text("file")
                    .frame(width: 72, height: 72)
            case .video:
                MessageLinkLocalVideoView(url: URL(fileURLWithPath: fileData.path), onTapRemove: onTapRemove)
                    .id(fileData.path)
            }
        } else {
            MessageLinkLocalDownloading(onTapRemove: onTapRemove)
        }
    }
}
