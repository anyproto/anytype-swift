import Foundation

protocol CoordinatorsDIProtocol: AnyObject {
    func legacyRelationValue() -> LegacyRelationValueCoordinatorAssembly
    func relationValue() -> RelationValueCoordinatorAssemblyProtocol
    func relationsList() -> RelationsListCoordinatorAssemblyProtocol
    func templates() -> TemplatesCoordinatorAssemblyProtocol
    func objectSettings() -> ObjectSettingsCoordinatorAssemblyProtocol
    func home() -> HomeCoordinatorAssemblyProtocol
    func application() -> ApplicationCoordinatorAssemblyProtocol
    func settings() -> SettingsCoordinatorAssemblyProtocol
    func spaceSettings() -> SpaceSettingsCoordinatorAssemblyProtocol
    func editor() -> EditorCoordinatorAssemblyProtocol
    func editorSet() -> EditorSetCoordinatorAssemblyProtocol
    func editorPage() -> EditorPageCoordinatorAssemblyProtocol
    func setObjectCreationSettings() -> SetObjectCreationSettingsCoordinatorAssemblyProtocol
    func spaceSwitch() -> SpaceSwitchCoordinatorAssemblyProtocol
    func setObjectCreation() -> SetObjectCreationCoordinatorAssemblyProtocol
    func sharingTip() -> SharingTipCoordinatorProtocol
    func typeSearchForNewObject() -> TypeSearchForNewObjectCoordinatorAssemblyProtocol
    
    // Now like a coordinator. Migrate to isolated modules
    func editorPageModule() -> EditorPageModuleAssemblyProtocol
    func editorSetModule() -> EditorSetModuleAssemblyProtocol
}
