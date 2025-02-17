import SwiftUI
import UIKit

struct ChatInputLocalPhotosFile: View {
    
    let localFile: ChatLocalPhotosFile
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
            ChatInputLocalFile(fileData: fileData, onTapObject: onTapObject, onTapRemove: onTapRemove)
        } else {
            ChatInputLocalDownloading(onTapRemove: onTapRemove)
        }
    }
}
