import SwiftUI

struct ModalNavigationHeader<LeftView: View, TitleView: View, RightView: View>: View {
    
    @ViewBuilder
    let leftView: LeftView
    @ViewBuilder
    let titleView: TitleView
    @ViewBuilder
    let rightView: RightView
    
    var body: some View {
        NavigationHeaderContainer(spacing: 20) {
            leftView
        } titleView: {
            titleView
        } rightView: {
            rightView
        }
        .padding(.horizontal, 16)
        .frame(height: 48)
    }
}

extension ModalNavigationHeader where TitleView == AnyView {
    init(title: String, @ViewBuilder leftView: () -> LeftView, @ViewBuilder rightView: () -> RightView) {
        self.titleView = AnytypeText(title, style: .uxTitle1Semibold)
            .foregroundColor(.Text.primary)
            .frame(height: 48)
            .lineLimit(1)
            .eraseToAnyView()
        self.leftView = leftView()
        self.rightView = rightView()
    }
}

extension ModalNavigationHeader where TitleView == AnyView, RightView == AnyView, LeftView == AnyView {
    init(title: String) {
        self.titleView = AnytypeText(title, style: .uxTitle1Semibold)
            .foregroundColor(.Text.primary)
            .frame(height: 48)
            .lineLimit(1)
            .eraseToAnyView()
        self.leftView = EmptyView().eraseToAnyView()
        self.rightView = EmptyView().eraseToAnyView()
    }
}
