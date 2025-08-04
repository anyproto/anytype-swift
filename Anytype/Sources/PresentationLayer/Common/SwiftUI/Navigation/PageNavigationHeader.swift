import SwiftUI

enum PageNavigationHeaderConstants {
    static let height: CGFloat = 52
}

struct PageNavigationHeader<TitleView: View, RightView: View>: View {
    
    @ViewBuilder
    let titleView: TitleView
    @ViewBuilder
    let rightView: RightView
    
    var body: some View {
        NavigationHeaderContainer(spacing: 20) {
            PageNavigationBackButton()
        } titleView: {
            titleView
        } rightView: {
            rightView
        }
        .padding(.horizontal, 16)
        .frame(height: PageNavigationHeaderConstants.height)
    }
}

extension PageNavigationHeader where TitleView == AnyView {
    init(title: String, @ViewBuilder rightView: () -> RightView) {
        self.titleView = AnytypeText(title, style: .uxTitle1Semibold)
            .foregroundColor(.Text.primary)
            .frame(height: 48)
            .lineLimit(1)
            .eraseToAnyView()
        self.rightView = rightView()
    }
}

extension PageNavigationHeader where TitleView == AnyView, RightView == AnyView {
    init(title: String) {
        self.titleView = AnytypeText(title, style: .uxTitle1Semibold)
            .foregroundColor(.Text.primary)
            .frame(height: 48)
            .lineLimit(1)
            .eraseToAnyView()
        self.rightView = EmptyView().eraseToAnyView()
    }
}
