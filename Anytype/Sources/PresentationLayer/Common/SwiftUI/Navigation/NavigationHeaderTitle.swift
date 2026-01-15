import SwiftUI

struct NavigationHeaderTitle: View {

    let title: String

    var body: some View {
        AnytypeText(title, style: .uxTitle1Semibold)
            .foregroundStyle(Color.Text.primary)
            .lineLimit(1)
            .frame(maxWidth: .infinity, alignment: .center)
    }
}
