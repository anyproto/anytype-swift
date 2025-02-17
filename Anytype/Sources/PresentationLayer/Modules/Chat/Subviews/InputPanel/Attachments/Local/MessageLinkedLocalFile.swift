import SwiftUI
import UIKit

struct MessageLinkedLocalFile: View {
    
    let fileData: FileData
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
        switch fileData.chatViewType {
        case .image:
            MessageLinkLocalImageView(contentsOfFile: fileData.path, onTapRemove: onTapRemove)
                .id(fileData.path)
        case .file:
            MessageLinkLocalBinaryFileView(path: fileData.path, type: fileData.type, sizeInBytes: fileData.sizeInBytes, onTapRemove: onTapRemove)
        case .video:
            ChatInputVideoView(url: URL(fileURLWithPath: fileData.path), onTapRemove: onTapRemove)
                .id(fileData.path)
        }
    }
}
