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
            if #available(iOS 17.0, *) {
                ScrollView {
                    content
                }
                .defaultScrollAnchor(.bottom)
//                .onChange(of: position) { newValue in
//                    if case let .bottom(id) = newValue {
//                        proxy.scrollTo(id, anchor: .bottom)
//                    }
//                }
            } else {
                // Fallback on earlier versions
            }
        }
    }
}
