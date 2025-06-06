import SwiftUI

struct MessageAttachmentErrorIndicator: View {
    
    var body: some View {
        ZStack {
            Image(asset: .Dialog.exclamation)
                .resizable()
                .frame(width: 52, height: 52)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.Shape.tertiary)
    }
}
