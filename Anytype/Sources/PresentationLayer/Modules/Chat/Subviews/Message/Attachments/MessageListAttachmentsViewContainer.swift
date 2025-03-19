import Foundation
import SwiftUI
import Services

struct MessageListAttachmentsViewContainer: View {

    let objects: [MessageAttachmentDetails]
    let position: MessageHorizontalPosition
    let onTapObject: (MessageAttachmentDetails) -> Void
    
    var body: some View {
        VStack(spacing: 4) {
            ForEach(objects, id: \.id) { details in
                content(for: details)
                    .onTapGesture {
                        if !details.loadingState {
                            onTapObject(details)
                        }
                    }
                    .if(details.loadingState) {
                        $0.redacted(reason: .placeholder)
                    }
            }
        }
    }
    
    @ViewBuilder
    private func content(for details: MessageAttachmentDetails) -> some View {
        switch details.resolvedLayoutValue {
        case .bookmark:
            MessageBookmarkView(details: details, position: position)
        default:
            MessageAttachmentView(details: details, position: position)
        }
    }
}
