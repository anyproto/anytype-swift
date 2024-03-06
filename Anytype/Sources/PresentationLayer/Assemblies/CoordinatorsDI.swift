import Foundation
import UIKit

final class CoordinatorsDI: CoordinatorsDIProtocol {
    
    private let serviceLocator: ServiceLocator
    private let modulesDI: ModulesDIProtocol
    private let uiHelpersDI: UIHelpersDIProtocol
    
    init(serviceLocator: ServiceLocator, modulesDI: ModulesDIProtocol, uiHelpersDI: UIHelpersDIProtocol) {
        self.serviceLocator = serviceLocator
        self.modulesDI = modulesDI
        self.uiHelpersDI = uiHelpersDI
    }
    
    // MARK: - CoordinatorsDIProtocol
    
    func legacyRelationValue() -> LegacyRelationValueCoordinatorAssembly {
        return LegacyRelationValueCoordinatorAssembly(
            modulesDI: modulesDI,
            uiHelpersDI: uiHelpersDI
        )
    }
    
    func relationValue() -> RelationValueCoordinatorAssemblyProtocol {
        return RelationValueCoordinatorAssembly(
            coordinatorsID: self,
            modulesDI: modulesDI
        )
    }
    
    func relationsList() -> RelationsListCoordinatorAssemblyProtocol {
        RelationsListCoordinatorAssembly(
            coordinatorsID: self,
            modulesDI: modulesDI,
            serviceLocator: serviceLocator
        )
    }
    
    func templates() -> TemplatesCoordinatorAssemblyProtocol {
        return TemplatesCoordinatorAssembly(serviceLocator: serviceLocator, coordinatorsDI: self)
    }

    func linkToObject() -> LinkToObjectCoordinatorAssemblyProtocol {
        return LinkToObjectCoordinatorAssembly(
            serviceLocator: serviceLocator,
            modulesDI: modulesDI,
            coordinatorsID: self,
            uiHelopersDI: uiHelpersDI
        )
    }
    
    func objectSettings() -> ObjectSettingsCoordinatorAssemblyProtocol {
        return ObjectSettingsCoordinatorAssembly(modulesDI: modulesDI, uiHelpersDI: uiHelpersDI, coordinatorsDI: self, serviceLocator: serviceLocator)
    }
    
    func addNewRelation() -> AddNewRelationCoordinatorAssemblyProtocol {
        return AddNewRelationCoordinatorAssembly(uiHelpersDI: uiHelpersDI, modulesDI: modulesDI)
    }
    
    @MainActor
    func home() -> HomeCoordinatorAssemblyProtocol {
        return HomeCoordinatorAssembly(
            coordinatorsID: self,
            modulesDI: modulesDI,
            serviceLocator: serviceLocator,
            uiHelpersDI: uiHelpersDI
        )
    }
    
    func createWidget() -> CreateWidgetCoordinatorAssemblyProtocol {
        return CreateWidgetCoordinatorAssembly(
            modulesDI: modulesDI,
            serviceLocator: serviceLocator,
            uiHelpersDI: uiHelpersDI
        )
    }

    func application() -> ApplicationCoordinatorAssemblyProtocol {
        return ApplicationCoordinatorAssembly(serviceLocator: serviceLocator, coordinatorsDI: self, uiHelpersDI: uiHelpersDI, modulesDI: modulesDI)
    }
    
    func settings() -> SettingsCoordinatorAssemblyProtocol {
        return SettingsCoordinatorAssembly(modulesDI: modulesDI, uiHelpersDI: uiHelpersDI, coordinatorsDI: self, serviceLocator: serviceLocator)
    }
    
    func authorization() -> AuthCoordinatorAssemblyProtocol {
        return AuthCoordinatorAssembly(modulesDI: modulesDI, coordinatorsID: self, uiHelpersDI: uiHelpersDI)
    }
    
    func joinFlow() -> JoinFlowCoordinatorAssemblyProtocol {
        return JoinFlowCoordinatorAssembly(modulesDI: modulesDI)
    }
    
    func loginFlow() -> LoginFlowCoordinatorAssemblyProtocol {
        return LoginFlowCoordinatorAssembly(modulesDI: modulesDI, uiHelpersDI: uiHelpersDI)
    }
    
    func spaceSettings() -> SpaceSettingsCoordinatorAssemblyProtocol {
        return SpaceSettingsCoordinatorAssembly(modulesDI: modulesDI, serviceLocator: serviceLocator, uiHelpersDI: uiHelpersDI, coordinatorsDI: self)
    }
    
    func setViewSettings() -> SetViewSettingsCoordinatorAssemblyProtocol {
        return SetViewSettingsCoordinatorAssembly(modulesDI: modulesDI, coordinatorsDI: self)
    }
    
    func setSortsList() -> SetSortsListCoordinatorAssemblyProtocol {
        return SetSortsListCoordinatorAssembly(modulesDI: modulesDI)
    }
    
    func setFiltersDate() -> SetFiltersDateCoordinatorAssemblyProtocol {
        SetFiltersDateCoordinatorAssembly(modulesDI: modulesDI)
    }
    
    func setFiltersSelection() -> SetFiltersSelectionCoordinatorAssemblyProtocol {
        SetFiltersSelectionCoordinatorAssembly(modulesDI: modulesDI, coordinatorsDI: self)
    }
    
    func setFiltersList() -> SetFiltersListCoordinatorAssemblyProtocol {
        SetFiltersListCoordinatorAssembly(modulesDI: modulesDI, coordinatorsDI: self)
    }
    
    func setLayoutSettings() -> SetLayoutSettingsCoordinatorAssemblyProtocol {
        SetLayoutSettingsCoordinatorAssembly(modulesDI: modulesDI)
    }
    
    func setRelations() -> SetRelationsCoordinatorAssemblyProtocol {
        SetRelationsCoordinatorAssembly(modulesDI: modulesDI, coordinatorsDI: self)
    }
    
    func setViewPicker() -> SetViewPickerCoordinatorAssemblyProtocol {
        SetViewPickerCoordinatorAssembly(modulesDI: modulesDI, coordinatorsDI: self)
    }
    
    func share() -> ShareCoordinatorAssemblyProtocol {
        ShareCoordinatorAssembly(modulesDI: modulesDI, serviceLocator: serviceLocator)
    }

    func editor() -> EditorCoordinatorAssemblyProtocol {
        EditorCoordinatorAssembly(coordinatorsID: self, modulesDI: modulesDI)
    }

    func editorSet() -> EditorSetCoordinatorAssemblyProtocol {
        EditorSetCoordinatorAssembly(coordinatorsID: self, modulesDI: modulesDI, serviceLocator: serviceLocator, uiHelpersDI: uiHelpersDI)
    }

    func editorPage() -> EditorPageCoordinatorAssemblyProtocol {
        EditorPageCoordinatorAssembly(coordinatorsID: self, modulesDI: modulesDI, serviceLocator: serviceLocator)
    }

    func setObjectCreationSettings() -> SetObjectCreationSettingsCoordinatorAssemblyProtocol {
        SetObjectCreationSettingsCoordinatorAssembly(modulesDI: modulesDI, uiHelpersDI: uiHelpersDI, coordinatorsDI: self)
    }

    func editorPageModule() -> EditorPageModuleAssemblyProtocol {
        EditorPageModuleAssembly(serviceLocator: serviceLocator, coordinatorsDI: self, modulesDI: modulesDI, uiHelpersDI: uiHelpersDI)
    }

    func editorSetModule() -> EditorSetModuleAssemblyProtocol {
        EditorSetModuleAssembly(serviceLocator: serviceLocator, coordinatorsDI: self, modulesDI: modulesDI, uiHelpersDI: uiHelpersDI)
    }

    func initial() -> InitialCoordinatorAssemblyProtocol {
        InitialCoordinatorAssembly(serviceLocator: serviceLocator)
    }

    func spaceSwitch() -> SpaceSwitchCoordinatorAssemblyProtocol {
        SpaceSwitchCoordinatorAssembly(modulesDI: modulesDI, coordinatorsDI: self)
    }
    
    func setObjectCreation() -> SetObjectCreationCoordinatorAssemblyProtocol {
        SetObjectCreationCoordinatorAssembly(
            serviceLocator: serviceLocator,
            modulesDI: modulesDI,
            uiHelpersDI: uiHelpersDI,
            coordinatorsDI: self
        )
    }
    
    func serverConfiguration() -> ServerConfigurationCoordinatorAssemblyProtocol {
        ServerConfigurationCoordinatorAssembly(modulesDI: modulesDI)
    }
    
    func sharingTip() -> SharingTipCoordinatorProtocol {
        SharingTipCoordinator(
            sharingTipAssembly: modulesDI.sharingTip(),
            navigationContext: uiHelpersDI.commonNavigationContext()
        )
    }
    
    func galleryInstallation() -> GalleryInstallationCoordinatorAssemblyProtocol {
        GalleryInstallationCoordinatorAssembly(modulesDI: modulesDI, serviceLocator: serviceLocator)
    }
    
    func notificationCoordinator() -> NotificationCoordinatorProtocol {
        NotificationCoordinator(
            notificationSubscriptionService: serviceLocator.notificationSubscriptionService(),
            commonNotificationAssembly: modulesDI.commonNotification(),
            galleryNotificationAssembly: modulesDI.galleryNotification()
        )
    }
    
    func selectRelationList() -> SelectRelationListCoordinatorAssemblyProtocol {
        SelectRelationListCoordinatorAssembly(modulesDI: modulesDI)
    }
    
    func objectRelationList() -> ObjectRelationListCoordinatorAssemblyProtocol {
        ObjectRelationListCoordinatorAssembly(modulesDI: modulesDI)
    }
    
    func spaceShare() -> SpaceShareCoordinatorAssemblyProtocol {
        SpaceShareCoordinatorAssembly(modulesDI: modulesDI)
    }
    
    func typeSearchForNewObject() -> TypeSearchForNewObjectCoordinatorAssemblyProtocol {
        TypeSearchForNewObjectCoordinatorAssembly(
            serviceLocator: serviceLocator,
            modulesDI: modulesDI
        )
    }
    
    func membership() -> MembershipCoordinatorAssemblyProtocol {
        MembershipCoordinatorAssembly(modulesDI: modulesDI)
    }
}
