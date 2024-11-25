import Foundation
import SwiftUI
import Services

struct MessageInputAttachmentsViewContainer: View {

    let objects: [ChatLinkedObject]
    let onTapObject: (ChatLinkedObject) -> Void
    let onTapRemove: (ChatLinkedObject) -> Void
    
    var body: some View {
        if objects.isNotEmpty {
            content
        }
    }
    
    private var content: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 12) {
                ForEach(objects) { object in
                    switch object {
                    case .uploadedObject(let details):
                        MessageLinkedUploadedObject(details: details) {
                            onTapObject(object)
                        } onTapRemove: {
                            onTapRemove(object)
                        }
                    case .localPhotosFile(let localFile):
                        MessageLinkedLocalPhotosFile(localFile: localFile) {
                            onTapObject(object)
                        } onTapRemove: {
                            onTapRemove(object)
                        }
                    case .localBinaryFile(let data):
                        MessageLinkedLocalFile(fileData: data) {
                            onTapObject(object)
                        } onTapRemove: {
                            onTapRemove(object)
                        }
                    }
                }
            }
            .padding(.top, 12)
            .padding(.horizontal, 12)
        }
        .scrollIndicators(.hidden)
    }
}
