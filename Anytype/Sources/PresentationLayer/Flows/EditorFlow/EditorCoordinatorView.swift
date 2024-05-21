import Foundation
import SwiftUI

struct EditorCoordinatorView: View {
    
    @StateObject private var model: EditorCoordinatorViewModel
    @Environment(\.pageNavigation) private var pageNavigation
    
    init(data: EditorScreenData) {
        self._model = StateObject(wrappedValue: EditorCoordinatorViewModel(data: data))
    }
    
    var body: some View {
        mainView
            .onAppear {
                model.pageNavigation = pageNavigation
            }
    }
    
    @ViewBuilder
    private var mainView: some View {
        switch model.data {
        case .favorites:
            WidgetObjectListFavoritesView(output: model)
        case .recentEdit:
            WidgetObjectListRecentEditView(output: model)
        case .recentOpen:
            WidgetObjectListRecentOpenView(output: model)
        case .sets:
            WidgetObjectListSetsView(output: model)
        case .collections:
            WidgetObjectListCollectionsView(output: model)
        case .bin:
            WidgetObjectListBinView(output: model)
        case .page(let data):
            EditorPageCoordinatorView(data: data, showHeader: true, setupEditorInput: { _, _ in })
        case .set(let data):
            EditorSetCoordinatorView(data: data)
        }
    }
}
