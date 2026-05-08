import Foundation
import SwiftUI
import Services

struct UnreadSectionView: View {

    let spaceId: String
    weak var output: (any CommonWidgetModuleOutput)?
    let onShouldHideBadgesChange: (Bool) -> Void

    var body: some View {
        UnreadSectionViewInternal(
            spaceId: spaceId,
            output: output,
            onShouldHideBadgesChange: onShouldHideBadgesChange
        )
    }
}

private struct UnreadSectionViewInternal: View {

    @State private var model: UnreadSectionViewModel
    let onShouldHideBadgesChange: (Bool) -> Void

    init(
        spaceId: String,
        output: (any CommonWidgetModuleOutput)?,
        onShouldHideBadgesChange: @escaping (Bool) -> Void
    ) {
        self.onShouldHideBadgesChange = onShouldHideBadgesChange
        self._model = State(wrappedValue: UnreadSectionViewModel(spaceId: spaceId, output: output))
    }

    var body: some View {
        // Outer always-rendered VStack so .task attaches to a stable view across the empty→non-empty transition.
        VStack(spacing: 0) {
            if model.shouldShowUnreadSection {
                HomeWidgetsGroupView(title: Loc.unread) {
                    model.onTapUnreadHeader()
                }
                if model.unreadSectionIsExpanded {
                    UnreadItemsGroupedView(
                        items: model.unreadItems,
                        onTap: { model.onRowTap(data: $0) }
                    )
                }
            }
        }
        .task {
            await model.startSubscriptions()
        }
        .onChange(of: model.shouldHideChatBadges, initial: true) { _, newValue in
            onShouldHideBadgesChange(newValue)
        }
    }
}
