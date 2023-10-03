import Foundation
import SwiftUI

protocol EditorSetModuleAssemblyProtocol: AnyObject {
    @MainActor
    func make(data: EditorSetObject, output: EditorSetModuleOutput?) -> AnyView
}

final class EditorSetModuleAssembly: EditorSetModuleAssemblyProtocol {
    
    private let serviceLocator: ServiceLocator
    // TODO: Delete coordinator dependency
    private let coordinatorsDI: CoordinatorsDIProtocol
    private let modulesDI: ModulesDIProtocol
    private let uiHelpersDI: UIHelpersDIProtocol
    
    init(
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
    
    @MainActor
    func make(data: EditorSetObject, output: EditorSetModuleOutput?) -> AnyView {
        return EditorSetView(model: self.setModel(browser: nil, data: data)).eraseToAnyView()
    }
    
    // MARK: - Private
    
    @MainActor
    private func setModel(browser: EditorBrowserController?, data: EditorSetObject) -> EditorSetViewModel {
        let document = BaseDocument(objectId: data.objectId)
        let setDocument = SetDocument(
            document: document,
            blockId: data.inline?.blockId,
            targetObjectID: data.inline?.targetObjectID,
            relationDetailsStorage: serviceLocator.relationDetailsStorage(),
            objectTypeProvider: serviceLocator.objectTypeProvider()
        )
        let dataviewService = serviceLocator.dataviewService(objectId: data.objectId, blockId: data.inline?.blockId)
        
        let detailsService = serviceLocator.detailsService(objectId: data.objectId)
        
        let headerModel = ObjectHeaderViewModel(
            document: setDocument,
            configuration: .init(
                isOpenedForPreview: false,
                shouldShowTemplateSelection: false,
                usecase: .editor
            ),
            interactor: serviceLocator.objectHeaderInteractor(objectId: setDocument.targetObjectID ?? setDocument.objectId)
        )
        
        let model = EditorSetViewModel(
            setDocument: setDocument,
            headerViewModel: headerModel,
            subscriptionService: serviceLocator.subscriptionService(),
            dataviewService: dataviewService,
            searchService: serviceLocator.searchService(),
            detailsService: detailsService,
            objectActionsService: serviceLocator.objectActionsService(),
            textService: serviceLocator.textService,
            groupsSubscriptionsHandler: serviceLocator.groupsSubscriptionsHandler(),
            setSubscriptionDataBuilder: SetSubscriptionDataBuilder(activeWorkspaceStorage: serviceLocator.activeWorkspaceStorage()),
            objectTypeProvider: serviceLocator.objectTypeProvider(),
            setTemplatesInteractor: serviceLocator.setTemplatesInteractor
        )

        let router = EditorSetRouter(
            setDocument: setDocument,
            rootController: browser,
            navigationContext: uiHelpersDI.commonNavigationContext(),
            createObjectModuleAssembly: modulesDI.createObject(),
            newSearchModuleAssembly: modulesDI.newSearch(),
            editorPageCoordinator: coordinatorsDI.editorPage().make(browserController: browser),
            objectSettingCoordinator: coordinatorsDI.objectSettings().make(browserController: browser),
            relationValueCoordinator: coordinatorsDI.relationValue().make(),
            objectCoverPickerModuleAssembly: modulesDI.objectCoverPicker(),
            objectIconPickerModuleAssembly: modulesDI.objectIconPicker(),
            setViewSettingsCoordinatorAssembly: coordinatorsDI.setViewSettings(),
            setSortsListCoordinatorAssembly: coordinatorsDI.setSortsList(),
            setFiltersListCoordinatorAssembly: coordinatorsDI.setFiltersList(),
            setViewSettingsImagePreviewModuleAssembly: modulesDI.setViewSettingsImagePreview(),
            setViewSettingsGroupByModuleAssembly: modulesDI.setViewSettingsGroupByView(),
            editorSetRelationsCoordinatorAssembly: coordinatorsDI.setRelations(),
            setViewPickerCoordinatorAssembly: coordinatorsDI.setViewPicker(),
            toastPresenter: uiHelpersDI.toastPresenter(using: browser),
            alertHelper: AlertHelper(viewController: nil),
            setObjectCreationSettingsCoordinator: coordinatorsDI.setObjectCreationSettings().make(
                with: .creation,
                navigationContext: uiHelpersDI.commonNavigationContext()
            )
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
