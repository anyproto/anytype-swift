import SwiftUI

struct DiscussionHeaderView: View {

    let objectName: String
    let commentsCount: Int
    let chatId: String?
    let onTapCopyLink: () -> Void

    var body: some View {
        NavigationHeader(
            navigationButtonType: .back
        ) {
            titleView
        } rightContent: {
            moreButton
        }
    }

    private var titleView: some View {
        VStack(alignment: .leading, spacing: 0) {
            AnytypeText(objectName.withPlaceholder, style: .caption1Regular)
                .foregroundStyle(Color.Text.secondary)
                .lineLimit(1)
            AnytypeText(commentsString, style: .uxTitle2Semibold)
                .foregroundStyle(Color.Text.primary)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: NavigationHeaderConstants.height)
    }

    private var commentsString: String {
        Loc.Discussion.Header.comments(commentsCount)
    }

    @ViewBuilder
    private var moreButton: some View {
        if chatId != nil {
            Menu {
                Button {
                    onTapCopyLink()
                } label: {
                    Label(Loc.copyLink, systemImage: "link")
                }
            } label: {
                Image(asset: .X24.more)
                    .foregroundStyle(Color.Control.primary)
                    .frame(width: NavigationHeaderConstants.buttonSize, height: NavigationHeaderConstants.buttonSize)
            }
            .glassEffectInteractiveIOS26(in: Circle())
        }
    }
}
