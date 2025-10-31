import Foundation
import SwiftUI
import AnytypeCore

struct EditorCoordinatorView: View {
    
    @StateObject private var model: EditorCoordinatorViewModel
    @Environment(\.pageNavigation) private var pageNavigation
    
    init(data: EditorScreenData) {
        self._model = StateObject(wrappedValue: EditorCoordinatorViewModel(data: data))
    }
    
    var body: some View {
        SpaceLoadingContainerView(spaceId: model.data.spaceId, showBackground: false) { _ in
            content
        }
    }
    
    private var content: some View {
        mainView
            .onAppear {
                model.pageNavigation = pageNavigation
            }
    }
    
    @ViewBuilder
    private var mainView: some View {
        switch model.data {
        case let .pinned(homeObjectId, spaceId):
            WidgetObjectListFavoritesView(homeObjectId: homeObjectId, spaceId: spaceId, output: model)
        case let .recentEdit(spaceId):
            WidgetObjectListRecentEditView(spaceId: spaceId, output: model)
        case let .recentOpen(spaceId):
            WidgetObjectListRecentOpenView(spaceId: spaceId, output: model)
        case let .bin(spaceId):
            BinListView(spaceId: spaceId, output: model)
        case let .page(data):
            EditorPageCoordinatorView(data: data, showHeader: true, setupEditorInput: { _, _ in })
        case let .list(data):
            EditorSetCoordinatorView(data: data, showHeader: true)
        case let .date(data):
            DateCoordinatorView(data: data)
        case let .type(data):
            let list = EditorListObject(objectId: data.objectId, spaceId: data.spaceId)
            EditorSetCoordinatorView(data: list, showHeader: true)
        }
    }
}
