import SwiftUI

struct MessageLinkLocalDownloading: View {
    
    let onTapRemove: () -> Void
    
    var body: some View {
        ZStack {
            DotsView()
                .frame(width: 40, height: 6)
        }
        .frame(width: 72, height: 72)
        .background(Color.Background.secondary)
        .messageLinkStyle()
        .messageLinkRemoveButton(onTapRemove: onTapRemove)
    }
}
