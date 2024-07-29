import Foundation
import SwiftUI
import Services

struct MessageLinkViewContainer: View {

    let objects: [ObjectDetails]
    let isYour: Bool
    
    var body: some View {
        VStack(spacing: 8) {
            ForEach(objects, id: \.id) {
                MessageLinkObjectView(details: $0, style: isYour ? .listMy : .listOther)
            }
        }
    }
}
