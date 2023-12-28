import Foundation
import SwiftUI

@MainActor
protocol EditorSetModuleAssemblyProtocol: AnyObject {
    func make(data: EditorSetObject, output: EditorSetModuleOutput?) -> AnyView
}

@MainActor
final class EditorSetModuleAssembly: EditorSetModuleAssemblyProtocol {
    
    private let serviceLocator: ServiceLocator
    // TODO: Delete coordinator dependency
    private let coordinatorsDI: CoordinatorsDIProtocol
    private let modulesDI: ModulesDIProtocol
    private let uiHelpersDI: UIHelpersDIProtocol
    
    nonisolated init(
        serviceLocator: ServiceLocator,
        coordinatorsDI: CoordinatorsDIProtocol,
        modulesDI: ModulesDIProtocol,
        uiHelpersDI: UIHelpersDIProtocol
    ) {
        self.serviceLocator = serviceLocator
        self.coordinatorsDI = coordinatorsDI
        self.modulesDI = modulesDI
        self.uiHelpersDI = uiHelpersDI
    }
    
    // MARK: - EditorSetModuleAssemblyProtocol
    
    func make(data: EditorSetObject, output: EditorSetModuleOutput?) -> AnyView {
        return EditorSetView(model: self.setModel(data: data, output: output)).eraseToAnyView()
    }
    
    // MARK: - Private

    private func setModel(data: EditorSetObject, output: EditorSetModuleOutput?) -> EditorSetViewModel {
        let setDocument = serviceLocator.documentsProvider.setDocument(
            objectId: data.objectId,
            forPreview: false,
            inlineParameters: data.inline
        )
        
        let detailsService = serviceLocator.detailsService(objectId: data.objectId)
        
        let headerModel = ObjectHeaderViewModel(
            document: setDocument,
            configuration: .init(
                isOpenedForPreview: false,
                usecase: .editor
            ),
            interactor: serviceLocator.objectHeaderInteractor(objectId: setDocument.targetObjectId)
        )
        
        let model = EditorSetViewModel(
            setDocument: setDocument,
            headerViewModel: headerModel,
            subscriptionStorageProvider: serviceLocator.subscriptionStorageProvider(),
            dataviewService: serviceLocator.dataviewService(),
            searchService: serviceLocator.searchService(),
            detailsService: detailsService,
            objectActionsService: serviceLocator.objectActionsService(),
            textServiceHandler: serviceLocator.textServiceHandler(),
            groupsSubscriptionsHandler: serviceLocator.groupsSubscriptionsHandler(),
            setSubscriptionDataBuilder: SetSubscriptionDataBuilder(activeWorkspaceStorage: serviceLocator.activeWorkspaceStorage()),
            setGroupSubscriptionDataBuilder: SetGroupSubscriptionDataBuilder(),
            objectTypeProvider: serviceLocator.objectTypeProvider(),
            activeWorkspaceStorage: serviceLocator.activeWorkspaceStorage(),
            output: output
        )

        let router = EditorSetRouter(
            setDocument: setDocument,
            navigationContext: uiHelpersDI.commonNavigationContext(),
            createObjectModuleAssembly: modulesDI.createObject(),
            newSearchModuleAssembly: modulesDI.newSearch(),
            objectSettingCoordinator: coordinatorsDI.objectSettings().make(),
            relationValueCoordinator: coordinatorsDI.relationValue().make(), 
            setObjectCreationCoordinator: coordinatorsDI.setObjectCreation().make(),
            objectCoverPickerModuleAssembly: modulesDI.objectCoverPicker(),
            objectIconPickerModuleAssembly: modulesDI.objectIconPicker(),
            setViewSettingsCoordinatorAssembly: coordinatorsDI.setViewSettings(),
            setSortsListCoordinatorAssembly: coordinatorsDI.setSortsList(),
            setFiltersListCoordinatorAssembly: coordinatorsDI.setFiltersList(),
            setViewSettingsImagePreviewModuleAssembly: modulesDI.setViewSettingsImagePreview(),
            setViewSettingsGroupByModuleAssembly: modulesDI.setViewSettingsGroupByView(),
            editorSetRelationsCoordinatorAssembly: coordinatorsDI.setRelations(),
            setViewPickerCoordinatorAssembly: coordinatorsDI.setViewPicker(),
            sharingTipCoordinator: SharingTipCoordinator(
                sharingTipAssembly: modulesDI.sharingTip(),
                navigationContext: uiHelpersDI.commonNavigationContext()
            ),
            toastPresenter: uiHelpersDI.toastPresenter(),
            setObjectCreationSettingsCoordinator: coordinatorsDI.setObjectCreationSettings().make(with: uiHelpersDI.commonNavigationContext()),
            output: output
        )
        
        setupHeaderModelActions(headerModel: headerModel, using: router)
        
        model.setup(router: router)
        
        return model
    }
    
    private func setupHeaderModelActions(headerModel: ObjectHeaderViewModel, using router: ObjectHeaderRouterProtocol) {
        headerModel.onCoverPickerTap = { [weak router] args in
            router?.showCoverPicker(document: args.0, onCoverAction: args.1)
        }
        
        headerModel.onIconPickerTap = { [weak router] args in
            router?.showIconPicker(document: args.0, onIconAction: args.1)
        }
    }
}
