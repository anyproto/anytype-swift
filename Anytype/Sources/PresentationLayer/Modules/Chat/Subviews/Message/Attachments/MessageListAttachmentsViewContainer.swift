import Foundation
import SwiftUI
import Services

struct MessageListAttachmentsViewContainer: View {

    let objects: [MessageAttachmentDetails]
    let onTapObject: (MessageAttachmentDetails) -> Void
    
    var body: some View {
        VStack(spacing: 8) {
            ForEach(objects, id: \.id) { details in
                MessageObjectAttachmentView(details: details)
                    .onTapGesture {
                        onTapObject(details)
                    }
            }
        }
    }
}
