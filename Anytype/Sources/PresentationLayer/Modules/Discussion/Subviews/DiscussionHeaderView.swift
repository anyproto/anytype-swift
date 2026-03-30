import SwiftUI
import Services

struct DiscussionHeaderView: View {

    let objectName: String
    let commentsCount: Int
    let chatId: String?
    let spaceId: String
    let settingsOutput: (any ObjectSettingsCoordinatorOutput)?

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
            AnytypeText(objectName, style: .caption1Regular)
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
        if let chatId {
            ObjectSettingsMenuContainer(
                objectId: chatId,
                spaceId: spaceId,
                output: settingsOutput
            ) {
                Image(asset: .X24.more)
                    .foregroundStyle(Color.Control.primary)
                    .frame(width: NavigationHeaderConstants.buttonSize, height: NavigationHeaderConstants.buttonSize)
            }
            .glassEffectInteractiveIOS26(in: Circle())
        }
    }
}
