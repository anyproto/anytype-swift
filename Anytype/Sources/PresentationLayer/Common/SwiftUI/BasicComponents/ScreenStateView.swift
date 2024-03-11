import Foundation
import SwiftUI

enum ScreenState {
    case data
    case error
    case loading
}

struct ScreenStateView<Content: View, Loading: View, ErrorT: View>: View {
    
    let state: ScreenState
    
    let content: () -> Content
    let loading: () -> Loading
    let error: () -> ErrorT
    
    init(state: ScreenState, @ViewBuilder content: @escaping () -> Content, @ViewBuilder loading: @escaping () -> Loading, @ViewBuilder error: @escaping () -> ErrorT) {
        self.state = state
        self.content = content
        self.loading = loading
        self.error = error
    }
    
    var body: some View {
        switch state {
        case .data:
            content()
        case .error:
            error()
        case .loading:
            loading()
        }
    }
}

extension ScreenStateView where ErrorT == ErrorStateView {
    init(state: ScreenState, error: String, @ViewBuilder content: @escaping () -> Content, @ViewBuilder loading: @escaping () -> Loading) {
        self.init(state: state, content: content, loading: loading) {
            ErrorStateView(message: error)
        }
    }
}

extension ScreenStateView where ErrorT == ErrorStateView, Loading == EmptyView {
    init(state: ScreenState, error: String, @ViewBuilder content: @escaping () -> Content) {
        self.init(state: state, content: content) {
            EmptyView()
        } error: {
            ErrorStateView(message: error)
        }
    }
}

#Preview("Data") {
    ScreenStateView(state: .data) {
        Color.green
    } loading: {
        Color.orange
    } error: {
        Color.red
    }
}

#Preview("Simple error") {
    ScreenStateView(state: .error, error: "Error desc") {
        Color.green
    }
}
