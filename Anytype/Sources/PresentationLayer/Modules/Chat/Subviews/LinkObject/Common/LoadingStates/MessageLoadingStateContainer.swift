import SwiftUI

struct MessageLoadingStateContainer<Content: View>: View {
    
    @ViewBuilder var content: () -> Content
    
    var body: some View {
        ViewThatFits {
            content()
                .frame(width: 52, height: 52)
            
            content()
                .frame(width: 30, height: 30)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
