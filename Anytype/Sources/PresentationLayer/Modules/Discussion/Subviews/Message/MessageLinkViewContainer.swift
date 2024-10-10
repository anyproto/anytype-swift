import Foundation
import SwiftUI
import Services

struct MessageLinkViewContainer: View {

    let objects: [MessageAttachmentDetails]
    let isYour: Bool
    let onTapObject: (MessageAttachmentDetails) -> Void
    
    var body: some View {
        VStack(spacing: 8) {
            ForEach(objects, id: \.id) { details in
                MessageLinkObjectView(details: details, style: isYour ? .listMy : .listOther)
                    .onTapGesture {
                        onTapObject(details)
                    }
            }
        }
    }
}
