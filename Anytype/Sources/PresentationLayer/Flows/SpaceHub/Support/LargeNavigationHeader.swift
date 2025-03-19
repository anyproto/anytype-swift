import SwiftUI

struct LargeNavigationHeader<TitleView: View, RightView: View>: View {
    
    @ViewBuilder
    let titleView: TitleView
    @ViewBuilder
    let rightView: RightView
    
    var body: some View {
        VStack(spacing: 0) {
            NavigationHeaderContainer(spacing: 20) {
                PageNavigationBackButton()
            } titleView: {
                EmptyView()
            } rightView: {
                rightView
            }
            .frame(height: 48)
            
            titleView
        }
        .padding(.horizontal, 16)
    }
}

extension LargeNavigationHeader where TitleView == AnyView {
    init(title: String, @ViewBuilder rightView: () -> RightView) {
        self.titleView = LargeNavigationHeader.defaultTextView(title: title)
        self.rightView = rightView()
    }
}

extension LargeNavigationHeader where TitleView == AnyView, RightView == AnyView {
    init(title: String) {
        self.titleView = LargeNavigationHeader.defaultTextView(title: title)
        self.rightView = EmptyView().eraseToAnyView()
    }
}

extension LargeNavigationHeader {
    static func defaultTextView(title: String) -> AnyView {
        AnytypeText(title, style: .title)
            .foregroundColor(.Text.primary)
            .frame(height: 64)
            .lineLimit(1)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading, 8)
            .eraseToAnyView()
    }
}
