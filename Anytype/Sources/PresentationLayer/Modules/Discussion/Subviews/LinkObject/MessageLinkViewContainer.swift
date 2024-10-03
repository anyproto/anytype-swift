import Foundation
import SwiftUI
import Services

struct MessageLinkViewContainer: View {

    let objects: [ObjectDetails]
    let isYour: Bool
    let onTapObject: (ObjectDetails) -> Void
    
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
