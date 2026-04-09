import SwiftUI

struct DiscussionCheckboxBlockView: View {

    let content: AttributedString
    let checked: Bool

    var body: some View {
        HStack(alignment: .top, spacing: 6) {
            Group {
                if checked {
                    Image(asset: .System.checkboxChecked)
                } else {
                    Image(asset: .System.checkboxUnchecked)
                }
            }
            .frame(width: 20, height: 20)
            Text(content)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
