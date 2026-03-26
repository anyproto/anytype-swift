import Foundation
import SwiftUI
import Services

struct DiscussionBookmarkBlockView: View {

    let details: ObjectDetails

    var body: some View {
        MessageCommonBookmarkView(
            icon: details.objectIconImage,
            title: details.source?.url.host() ?? details.source?.absoluteString ?? "",
            description: details.title,
            style: .messageOther
        )
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.Shape.transparentSecondary)
        .clipShape(.rect(cornerRadius: 12))
    }
}
