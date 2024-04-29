import Foundation
import SwiftUI

@MainActor
protocol WidgetObjectListModuleAssemblyProtocol: AnyObject {
    func makeFavorites(output: WidgetObjectListCommonModuleOutput?) -> AnyView
    func makeRecentEdit(output: WidgetObjectListCommonModuleOutput?) -> AnyView
    func makeRecentOpen(output: WidgetObjectListCommonModuleOutput?) -> AnyView
    func makeSets(output: WidgetObjectListCommonModuleOutput?) -> AnyView
    func makeCollections(output: WidgetObjectListCommonModuleOutput?) -> AnyView
    func makeBin(output: WidgetObjectListCommonModuleOutput?) -> AnyView
    func makeFiles() -> AnyView
}

@MainActor
final class WidgetObjectListModuleAssembly: WidgetObjectListModuleAssemblyProtocol {
    
    private let uiHelpersDI: UIHelpersDIProtocol
    
    nonisolated init(uiHelpersDI: UIHelpersDIProtocol) {
        self.uiHelpersDI = uiHelpersDI
    }
    
    // MARK: - WidgetObjectListModuleAssemblyProtocol
    
    func makeFavorites(output: WidgetObjectListCommonModuleOutput?) -> AnyView {
        return make(
            internalModel: WidgetObjectListFavoritesViewModel(),
            output: output
        )
    }
    
    func makeRecentEdit(output: WidgetObjectListCommonModuleOutput?) -> AnyView {
        return make(
            internalModel: WidgetObjectListRecentViewModel(type: .recentEdit),
            output: output
        )
    }
    
    func makeRecentOpen(output: WidgetObjectListCommonModuleOutput?) -> AnyView {
        return make(
            internalModel: WidgetObjectListRecentViewModel(type: .recentOpen),
            output: output
        )
    }
    
    func makeSets(output: WidgetObjectListCommonModuleOutput?) -> AnyView {
        return make(
            internalModel: WidgetObjectListSetsViewModel(),
            output: output
        )
    }
    
    func makeCollections(output: WidgetObjectListCommonModuleOutput?) -> AnyView {
        return make(
            internalModel: WidgetObjectListCollectionsViewModel(),
            output: output
        )
    }
    
    func makeBin(output: WidgetObjectListCommonModuleOutput?) -> AnyView {
        return make(
            internalModel: WidgetObjectListBinViewModel(),
            output: output
        )
    }
    
    func makeFiles() -> AnyView {
        return make(
            internalModel: WidgetObjectListFilesViewModel(),
            output: nil,
            isSheet: true
        )
    }
    
    // MARK: - Private
    
    private func make(
        internalModel: @autoclosure @escaping () -> WidgetObjectListInternalViewModelProtocol,
        output: WidgetObjectListCommonModuleOutput?,
        isSheet: Bool = false
    ) -> AnyView {
        
        let view = WidgetObjectListView(model: WidgetObjectListViewModel(
            internalModel: internalModel(),
            menuBuilder: WidgetObjectListMenuBuilder(),
            output: output,
            isSheet: isSheet
        ))
        return view.eraseToAnyView()
    }
}
