import Foundation
import SwiftUI

struct NavigationHeaderContainer<LeftView: View, TitleView: View, RightView: View>: View {
    
    let spacing: CGFloat
    @ViewBuilder
    let leftView: LeftView
    @ViewBuilder
    let titleView: TitleView
    @ViewBuilder
    let rightView: RightView
    
    @State private var leftSize: CGSize = .zero
    @State private var rightSize: CGSize = .zero
    
    var body: some View {
        HStack(spacing: spacing) {
            leftView
                .readSize { leftSize = $0 }
                .padding(.trailing, max(rightSize.width - leftSize.width, 0))
            titleView
                .frame(maxWidth: .infinity)
            rightView
                .readSize { rightSize = $0 }
                .padding(.leading, max(leftSize.width - rightSize.width, 0))
        }
    }
}
