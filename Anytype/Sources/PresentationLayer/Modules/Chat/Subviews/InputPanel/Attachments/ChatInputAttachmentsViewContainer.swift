import Foundation
import SwiftUI
import Services

struct ChatInputAttachmentsViewContainer: View {

    let objects: [ChatLinkedObject]
    let onTapObject: (ChatLinkedObject) -> Void
    let onTapRemove: (ChatLinkedObject) -> Void
    
    var body: some View {
        if objects.isNotEmpty {
            content
        }
    }
    
    private var content: some View {
        ScrollViewReader { reader in
            ScrollView(.horizontal) {
                HStack(spacing: 12) {
                    ForEach(objects) { object in
                        switch object {
                        case .uploadedObject(let details):
                            ChatInputUploadedObject(details: details) {
                                onTapObject(object)
                            } onTapRemove: {
                                onTapRemove(object)
                            }
                        case .localPhotosFile(let localFile):
                            ChatInputLocalPhotosFile(localFile: localFile) {
                                onTapObject(object)
                            } onTapRemove: {
                                onTapRemove(object)
                            }
                        case .localBinaryFile(let data):
                            ChatInputLocalFile(fileData: data) {
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
            .onChange(of: objects) { newValue in
                if objects.count < newValue.count, let last = newValue.last {
                    reader.scrollTo(last.id, anchor: .bottom)
                }
            }
        }
    }
}
