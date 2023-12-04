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
    
    private let serviceLocator: ServiceLocator
    private let uiHelpersDI: UIHelpersDIProtocol
    
    nonisolated init(serviceLocator: ServiceLocator, uiHelpersDI: UIHelpersDIProtocol) {
        self.serviceLocator = serviceLocator
        self.uiHelpersDI = uiHelpersDI
    }
    
    // MARK: - WidgetObjectListModuleAssemblyProtocol
    
    func makeFavorites(output: WidgetObjectListCommonModuleOutput?) -> AnyView {
        return make(
            internalModel: WidgetObjectListFavoritesViewModel(
                favoriteSubscriptionService: self.serviceLocator.favoriteSubscriptionService(),
                activeWorkspaceStorage: self.serviceLocator.activeWorkspaceStorage(),
                documentService: self.serviceLocator.documentService(),
                objectActionService: self.serviceLocator.objectActionsService()
            ),
            output: output
        )
    }
    
    func makeRecentEdit(output: WidgetObjectListCommonModuleOutput?) -> AnyView {
        return make(
            internalModel: WidgetObjectListRecentViewModel(
                type: .recentEdit,
                recentSubscriptionService: self.serviceLocator.recentSubscriptionService()
            ),
            output: output
        )
    }
    
    func makeRecentOpen(output: WidgetObjectListCommonModuleOutput?) -> AnyView {
        return make(
            internalModel: WidgetObjectListRecentViewModel(
                type: .recentOpen,
                recentSubscriptionService: self.serviceLocator.recentSubscriptionService()
            ),
            output: output
        )
    }
    
    func makeSets(output: WidgetObjectListCommonModuleOutput?) -> AnyView {
        return make(
            internalModel: WidgetObjectListSetsViewModel(setsSubscriptionService: self.serviceLocator.setsSubscriptionService()),
            output: output
        )
    }
    
    func makeCollections(output: WidgetObjectListCommonModuleOutput?) -> AnyView {
        return make(
            internalModel: WidgetObjectListCollectionsViewModel(subscriptionService: self.serviceLocator.collectionsSubscriptionService()),
            output: output
        )
    }
    
    func makeBin(output: WidgetObjectListCommonModuleOutput?) -> AnyView {
        return make(
            internalModel: WidgetObjectListBinViewModel(binSubscriptionService: self.serviceLocator.binSubscriptionService()),
            output: output
        )
    }
    
    func makeFiles() -> AnyView {
        return make(
            internalModel: WidgetObjectListFilesViewModel(subscriptionService: self.serviceLocator.filesSubscriptionManager()),
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
            objectActionService: self.serviceLocator.objectActionsService(),
            menuBuilder: WidgetObjectListMenuBuilder(),
            alertOpener: self.uiHelpersDI.alertOpener(),
            output: output,
            isSheet: isSheet
        ))
        return view.eraseToAnyView()
    }
}
