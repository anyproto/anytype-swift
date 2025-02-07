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
        case let .favorites(homeObjectId, spaceId):
            WidgetObjectListFavoritesView(homeObjectId: homeObjectId, spaceId: spaceId, output: model)
        case let .recentEdit(spaceId):
            WidgetObjectListRecentEditView(spaceId: spaceId, output: model)
        case let .recentOpen(spaceId):
            WidgetObjectListRecentOpenView(spaceId: spaceId, output: model)
        case let .sets(spaceId):
            WidgetObjectListSetsView(spaceId: spaceId, output: model)
        case let .collections(spaceId):
            WidgetObjectListCollectionsView(spaceId: spaceId, output: model)
        case let .bin(spaceId):
            WidgetObjectListBinView(spaceId: spaceId, output: model)
        case let .pages(spaceId):
            WidgetObjectListPagesView(spaceId: spaceId, output: model)
        case let .lists(spaceId):
            WidgetObjectListListsView(spaceId: spaceId, output: model)
        case let .media(spaceId):
            WidgetObjectListMediaView(spaceId: spaceId, output: model)
        case let .bookmarks(spaceId):
            WidgetObjectListBookmarksView(spaceId: spaceId, output: model)
        case let .files(spaceId):
            WidgetObjectListFilesView(spaceId: spaceId, output: model)
        case let .page(data):
            EditorPageCoordinatorView(data: data, showHeader: true, setupEditorInput: { _, _ in })
        case let .list(data):
            EditorSetCoordinatorView(data: data, showHeader: true)
        case let .allContent(spaceId):
            AllContentCoordinatorView(spaceId: spaceId, output: model)
        case let .date(data):
            DateCoordinatorView(data: data)
        case let .type(data):
            ObjectTypeCoordinator(data: data)
        }
    }
}
