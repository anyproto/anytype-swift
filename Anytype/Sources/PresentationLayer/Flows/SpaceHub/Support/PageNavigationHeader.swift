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
        HStack(spacing: 20) {
            PageNavigationBackButton()
            titleView
                .frame(maxWidth: .infinity)
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
