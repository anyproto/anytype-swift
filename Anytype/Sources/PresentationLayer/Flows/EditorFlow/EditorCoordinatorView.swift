import Foundation
import SwiftUI

struct EditorCoordinatorView: View {
    
    @StateObject var model: EditorCoordinatorViewModel
    @Environment(\.pageNavigation) private var pageNavigation
    
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
            model.makePage(data: data)
        case .set(let data):
            model.makeSet(data: data)
        }
    }
}
