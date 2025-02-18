import SwiftUI
import UIKit

struct ChatInputLocalFile: View {
    
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
            ChatInputLocalImageView(contentsOfFile: fileData.path, onTapRemove: onTapRemove)
                .id(fileData.path)
        case .file:
            ChatInputLocalBinaryFileView(path: fileData.path, type: fileData.type, sizeInBytes: fileData.sizeInBytes, onTapRemove: onTapRemove)
        case .video:
            ChatInputVideoView(url: URL(fileURLWithPath: fileData.path), onTapRemove: onTapRemove)
                .id(fileData.path)
        }
    }
}
