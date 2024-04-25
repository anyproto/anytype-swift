import SwiftUI

struct TitleView<RightContent>: View where RightContent: View {
    
    let title: String?
    let rightButton: RightContent?
    
    init(title: String?, @ViewBuilder rightButton: () -> RightContent) {
        self.title = title
        self.rightButton = rightButton()
    }
    
    var body: some View {
        HStack {
            Spacer()
            if let title = title {
                AnytypeText(title, style: .uxTitle1Semibold)
                    .foregroundColor(.Text.primary)
                    .frame(height: 48)
            }
            Spacer()
        }
        .overlay(rightButton, alignment: .trailing)
        .padding(.horizontal, 16)
    }
}

extension TitleView where RightContent == EmptyView {
    init(title: String?) {
        self.title = title
        self.rightButton = EmptyView()
    }
}

struct TitleView_Previews: PreviewProvider {
    static var previews: some View {
        TitleView(title: "title")
    }
}
