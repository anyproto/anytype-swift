import Foundation
import SwiftUI

enum DiscussionScrollViewPosition: Equatable {
    case bottom(_ id: String)
    case none
}

struct DiscussionScrollView<Content: View>: View {
    
    @Binding var position: DiscussionScrollViewPosition
    @ViewBuilder var content: Content
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                content
            }
            .onChange(of: position) { newValue in
                if case let .bottom(id) = newValue {
                    proxy.scrollTo(id, anchor: .bottom)
                }
            }
        }
    }
}
