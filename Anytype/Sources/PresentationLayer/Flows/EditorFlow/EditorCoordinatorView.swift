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
        mainView
            .onAppear {
                model.pageNavigation = pageNavigation
            }
            .attachSpaceLoadingContainer(spaceId: model.data.spaceId)
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
        case let .bin(spaceId):
            if FeatureFlags.binScreenEmptyAction {
                BinListView(spaceId: spaceId)
            } else {
                WidgetObjectListBinView(spaceId: spaceId, output: model)
            }
        case let .page(data):
            EditorPageCoordinatorView(data: data, showHeader: true, setupEditorInput: { _, _ in })
        case let .list(data):
            EditorSetCoordinatorView(data: data, showHeader: true)
        case let .allObjects(spaceId):
            AllObjectsCoordinatorView(spaceId: spaceId, output: model)
        case let .date(data):
            DateCoordinatorView(data: data)
        case let .simpleSet(data):
            SimpleSetCoordinatorView(data: data)
        case let .type(data):
            let list = EditorListObject(objectId: data.objectId, spaceId: data.spaceId)
            EditorSetCoordinatorView(data: list, showHeader: true)
        }
    }
}
