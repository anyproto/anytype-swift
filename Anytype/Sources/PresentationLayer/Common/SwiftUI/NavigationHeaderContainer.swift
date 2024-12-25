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
        ZStack(alignment: .center) {
            titleView
                .padding(.horizontal, max(leftSize.width, rightSize.width) + spacing)
            
            HStack(spacing: 0) {
                leftView
                    .readSize { leftSize = $0 }
                Spacer()
                rightView
                    .readSize { rightSize = $0 }
            }
        }
    }
}
