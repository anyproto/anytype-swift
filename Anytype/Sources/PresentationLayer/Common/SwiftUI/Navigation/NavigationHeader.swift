import SwiftUI


struct NavigationHeader<TitleView: View, RightView: View>: View {
    
    @Environment(\.dismiss) var dismiss
    
    @ViewBuilder
    let titleView: TitleView
    @ViewBuilder
    let rightView: RightView
    
    var body: some View {
        NavigationHeaderContainer(spacing: 20) {
            IncreaseTapButton {
                dismiss()
            } label: {
                Image(asset: .X24.back)
                    .navPanelDynamicForegroundStyle()
            }
        } titleView: {
            titleView
        } rightView: {
            rightView
        }
        .padding(.horizontal, 16)
        .frame(height: PageNavigationHeaderConstants.height)
        .background {
            HomeBlurEffectView(direction: .topToBottom)
                .ignoresSafeArea()
        }
    }
}

extension NavigationHeader where TitleView == AnyView {
    init(title: String, @ViewBuilder rightView: () -> RightView) {
        self.titleView = AnytypeText(title, style: .uxTitle1Semibold)
            .foregroundColor(.Text.primary)
            .frame(height: 48)
            .lineLimit(1)
            .eraseToAnyView()
        self.rightView = rightView()
    }
}

extension NavigationHeader where TitleView == AnyView, RightView == AnyView {
    init(title: String) {
        self.init(title: title, rightView: { EmptyView().eraseToAnyView() })
    }
}
