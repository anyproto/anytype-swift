import Foundation
import SwiftUI
import Services

struct MessageListAttachmentsViewContainer: View {

    let objects: [MessageAttachmentDetails]
    let isYour: Bool
    let onTapObject: (MessageAttachmentDetails) -> Void
    
    var body: some View {
        VStack(spacing: 4) {
            ForEach(objects, id: \.id) { details in
                content(for: details, isYour: isYour)
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
    private func content(for details: MessageAttachmentDetails, isYour: Bool) -> some View {
        switch details.resolvedLayoutValue {
        case .bookmark:
            MessageBookmarkView(details: details, isYour: isYour)
        default:
            MessageAttachmentView(details: details, isYour: isYour)
        }
    }
}
