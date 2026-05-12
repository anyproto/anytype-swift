import Foundation
import SwiftUI
import Services

struct MyFavoritesSectionView: View {

    let spaceId: String
    let personalWidgetsObject: any BaseDocumentProtocol
    let channelWidgetsObject: any BaseDocumentProtocol
    weak var output: (any CommonWidgetModuleOutput)?

    var body: some View {
        MyFavoritesSectionViewInternal(
            spaceId: spaceId,
            personalWidgetsObject: personalWidgetsObject,
            channelWidgetsObject: channelWidgetsObject,
            output: output
        )
    }
}

private struct MyFavoritesSectionViewInternal: View {

    @State private var model: MyFavoritesSectionViewModel

    init(
        spaceId: String,
        personalWidgetsObject: any BaseDocumentProtocol,
        channelWidgetsObject: any BaseDocumentProtocol,
        output: (any CommonWidgetModuleOutput)?
    ) {
        self._model = State(
            wrappedValue: MyFavoritesSectionViewModel(
                spaceId: spaceId,
                personalWidgetsObject: personalWidgetsObject,
                channelWidgetsObject: channelWidgetsObject,
                output: output
            )
        )
    }

    var body: some View {
        // Outer always-rendered VStack so .task attaches to a stable view across the empty→non-empty transition.
        VStack(spacing: 0) {
            if model.listModel.rows.isNotEmpty {
                HomeWidgetsGroupView(title: Loc.myFavorites) {
                    model.onTapHeader()
                }
                if model.isExpanded {
                    MyFavoritesListView(model: model.listModel)
                        .transition(.sectionBody)
                }
            }
        }
        .task {
            await model.startSubscriptions()
        }
    }
}
