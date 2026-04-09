import SwiftUI

struct DiscussionCheckboxBlockView: View {

    let content: AttributedString
    let checked: Bool

    var body: some View {
        HStack(alignment: .top, spacing: 6) {
            checkboxIcon
                .frame(width: 20, height: 20)
            Text(content)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    @ViewBuilder
    private var checkboxIcon: some View {
        if checked {
            ZStack {
                Circle()
                    .foregroundStyle(Color.Control.accent100)
                Image(asset: .X18.tick)
                    .resizable()
                    .padding(3)
                    .foregroundStyle(Color.Control.white)
            }
            .frame(width: 18, height: 18)
        } else {
            Circle()
                .stroke(Color.Control.tertiary, lineWidth: 1)
                .frame(width: 18, height: 18)
        }
    }
}
