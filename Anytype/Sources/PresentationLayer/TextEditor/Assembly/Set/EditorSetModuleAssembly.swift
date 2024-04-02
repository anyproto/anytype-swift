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
        
        let headerModel = ObjectHeaderViewModel(
            document: setDocument,
            targetObjectId: setDocument.targetObjectId,
            configuration: .init(
                isOpenedForPreview: false,
                usecase: .editor
            ),
            interactor: serviceLocator.objectHeaderInteractor(),
            output: output
        )
        
        let model = EditorSetViewModel(
            setDocument: setDocument,
            headerViewModel: headerModel,
            subscriptionStorageProvider: serviceLocator.subscriptionStorageProvider(),
            dataviewService: serviceLocator.dataviewService(),
            searchService: serviceLocator.searchService(),
            detailsService: serviceLocator.detailsService(),
            objectActionsService: serviceLocator.objectActionsService(), 
            relationsService: serviceLocator.relationService(),
            textServiceHandler: serviceLocator.textServiceHandler(),
            groupsSubscriptionsHandler: serviceLocator.groupsSubscriptionsHandler(),
            setSubscriptionDataBuilder: SetSubscriptionDataBuilder(activeWorkspaceStorage: serviceLocator.activeWorkspaceStorage()),
            setGroupSubscriptionDataBuilder: SetGroupSubscriptionDataBuilder(),
            objectTypeProvider: serviceLocator.objectTypeProvider(),
            activeWorkspaceStorage: serviceLocator.activeWorkspaceStorage(),
            output: output
        )
        
        setupHeaderModelActions(headerModel: headerModel, using: output)
        
        return model
    }
    
    private func setupHeaderModelActions(headerModel: ObjectHeaderViewModel, using output: EditorSetModuleOutput?) {
        headerModel.onIconPickerTap = { args in
            output?.showIconPicker(document: args.0, onIconAction: args.1)
        }
    }
}
