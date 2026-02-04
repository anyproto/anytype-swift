import SwiftUI

struct TitleView<LeftContent, RightContent>: View where LeftContent: View, RightContent: View {

    let title: String?
    let leftButton: LeftContent?
    let rightButton: RightContent?

    init(title: String?, @ViewBuilder leftButton: () -> LeftContent, @ViewBuilder rightButton: () -> RightContent) {
        self.title = title
        self.leftButton = leftButton()
        self.rightButton = rightButton()
    }

    var body: some View {
        HStack {
            Spacer()
            if let title = title {
                AnytypeText(title, style: .uxTitle1Semibold)
                    .foregroundStyle(Color.Text.primary)
                    .frame(height: 48)
            }
            Spacer()
        }
        .overlay(leftButton, alignment: .leading)
        .overlay(rightButton, alignment: .trailing)
        .padding(.horizontal, 16)
    }
}

extension TitleView where LeftContent == EmptyView {
    init(title: String?, @ViewBuilder rightButton: () -> RightContent) {
        self.title = title
        self.leftButton = EmptyView()
        self.rightButton = rightButton()
    }
}

extension TitleView where LeftContent == EmptyView, RightContent == EmptyView {
    init(title: String?) {
        self.title = title
        self.leftButton = EmptyView()
        self.rightButton = EmptyView()
    }
}

struct TitleView_Previews: PreviewProvider {
    static var previews: some View {
        TitleView(title: "title")
    }
}
