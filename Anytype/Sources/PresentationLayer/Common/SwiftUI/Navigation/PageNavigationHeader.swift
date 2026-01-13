import SwiftUI

enum PageNavigationHeaderConstants {
    static let height: CGFloat = 52
}

enum PageNavigationButtonType: Hashable {
    case burger
    case arrowBack
}

struct PageNavigationHeader<TitleView: View, RightView: View>: View {

    let navigationButtonType: PageNavigationButtonType
    @ViewBuilder
    let titleView: TitleView
    @ViewBuilder
    let rightView: RightView

    init(
        navigationButtonType: PageNavigationButtonType = .arrowBack,
        @ViewBuilder titleView: () -> TitleView,
        @ViewBuilder rightView: () -> RightView
    ) {
        self.navigationButtonType = navigationButtonType
        self.titleView = titleView()
        self.rightView = rightView()
    }

    var body: some View {
        NavigationHeaderContainer(spacing: 20) {
            leftButton
        } titleView: {
            titleView
        } rightView: {
            rightView
        }
        .padding(.horizontal, 16)
        .frame(height: PageNavigationHeaderConstants.height)
    }

    @ViewBuilder
    private var leftButton: some View {
        switch navigationButtonType {
        case .arrowBack:
            PageNavigationBackButton()
        case .burger:
            PageNavigationBurgerButton()
        }
    }
}

extension PageNavigationHeader where TitleView == AnyView {
    init(
        title: String,
        navigationButtonType: PageNavigationButtonType = .arrowBack,
        @ViewBuilder rightView: () -> RightView
    ) {
        self.navigationButtonType = navigationButtonType
        self.titleView = AnytypeText(title, style: .uxTitle1Semibold)
            .foregroundStyle(Color.Text.primary)
            .frame(height: 48)
            .lineLimit(1)
            .eraseToAnyView()
        self.rightView = rightView()
    }
}

extension PageNavigationHeader where TitleView == AnyView, RightView == AnyView {
    init(title: String, navigationButtonType: PageNavigationButtonType = .arrowBack) {
        self.navigationButtonType = navigationButtonType
        self.titleView = AnytypeText(title, style: .uxTitle1Semibold)
            .foregroundStyle(Color.Text.primary)
            .frame(height: 48)
            .lineLimit(1)
            .eraseToAnyView()
        self.rightView = EmptyView().eraseToAnyView()
    }
}
