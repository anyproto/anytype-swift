import Foundation
import SwiftUI
import Services

struct RecentlyEditedSectionView: View {

    let spaceId: String
    weak var output: (any CommonWidgetModuleOutput)?

    var body: some View {
        RecentlyEditedSectionViewInternal(
            spaceId: spaceId,
            output: output
        )
    }
}

private struct RecentlyEditedSectionViewInternal: View {

    @State private var model: RecentlyEditedSectionViewModel

    init(
        spaceId: String,
        output: (any CommonWidgetModuleOutput)?
    ) {
        self._model = State(
            wrappedValue: RecentlyEditedSectionViewModel(
                spaceId: spaceId,
                output: output
            )
        )
    }

    var body: some View {
        // Outer always-rendered VStack so .task attaches to a stable view across the empty→non-empty transition.
        VStack(spacing: 0) {
            if model.listModel.rows.isNotEmpty {
                HomeWidgetsGroupView(title: Loc.Widgets.Library.RecentlyEdited.name) {
                    model.onTapHeader()
                }
                if model.isExpanded {
                    RecentlyEditedListView(model: model.listModel)
                        .transition(.sectionBody)
                }
            }
        }
        .task {
            await model.startSubscriptions()
        }
    }
}
