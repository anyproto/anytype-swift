import SwiftUI
import UIKit

struct MessageLinkedLocalPhotosFile: View {
    
    let localFile: DiscussionLocalPhotosFile
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
            MessageLinkedLocalFile(fileData: fileData, onTapObject: onTapObject, onTapRemove: onTapRemove)
        } else {
            MessageLinkLocalDownloading(onTapRemove: onTapRemove)
        }
    }
}
