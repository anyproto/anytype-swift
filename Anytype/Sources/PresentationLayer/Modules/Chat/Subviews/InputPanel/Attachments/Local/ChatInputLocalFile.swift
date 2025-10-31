import SwiftUI
import UIKit

struct ChatInputLocalFile: View {
    
    let fileData: ChatLocalBinaryFile
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
        switch fileData.data.chatViewType {
        case .image:
            ChatInputLocalImageView(contentsOfFile: fileData.data.path, onTapRemove: onTapRemove)
                .id(fileData.data.path)
        case .file:
            ChatInputLocalBinaryFileView(path: fileData.data.path, type: fileData.data.type, sizeInBytes: fileData.data.sizeInBytes, onTapRemove: onTapRemove)
        case .video:
            ChatInputVideoView(url: URL(fileURLWithPath: fileData.data.path), onTapRemove: onTapRemove)
                .id(fileData.data.path)
        }
    }
}
