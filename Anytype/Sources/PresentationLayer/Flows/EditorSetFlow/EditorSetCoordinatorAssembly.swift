import Foundation
import SwiftUI

protocol EditorSetCoordinatorAssemblyProtocol {
    @MainActor
    func make(data: EditorSetObject) -> AnyView
}

final class EditorSetCoordinatorAssembly: EditorSetCoordinatorAssemblyProtocol {
    
    private let coordinatorsID: CoordinatorsDIProtocol
    private let serviceLocator: ServiceLocator
    private let uiHelpersDI: UIHelpersDIProtocol
    
    init(
        coordinatorsID: CoordinatorsDIProtocol,
        serviceLocator: ServiceLocator,
        uiHelpersDI: UIHelpersDIProtocol
    ) {
        self.coordinatorsID = coordinatorsID
        self.serviceLocator = serviceLocator
        self.uiHelpersDI = uiHelpersDI
    }
    
    // MARK: - EditorSetCoordinatorAssemblyProtocol
    
    @MainActor
    func make(data: EditorSetObject) -> AnyView {
        EditorSetCoordinatorView(
            model: EditorSetCoordinatorViewModel(
                data: data,
                editorSetAssembly: self.coordinatorsID.editorSetModule(), 
                setViewPickerCoordinatorAssembly: self.coordinatorsID.setViewPicker(),
                setObjectCreationCoordinator: self.coordinatorsID.setObjectCreation().make(), 
                objectSettingCoordinatorAssembly: self.coordinatorsID.objectSettings(),
                legacyRelationValueCoordinator: self.coordinatorsID.legacyRelationValue().make(), 
                setObjectCreationSettingsCoordinator: self.coordinatorsID.setObjectCreationSettings().make(with: nil), 
                relationValueCoordinatorAssembly: self.coordinatorsID.relationValue(), 
                relationValueProcessingService: self.serviceLocator.relationValueProcessingService(),
                toastPresenter: self.uiHelpersDI.toastPresenter(),
                navigationContext: self.uiHelpersDI.commonNavigationContext()
            )
        ).eraseToAnyView()
    }
}

