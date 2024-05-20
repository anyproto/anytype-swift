import Foundation

protocol CoordinatorsDIProtocol: AnyObject {
    func templates() -> TemplatesCoordinatorAssemblyProtocol
    func home() -> HomeCoordinatorAssemblyProtocol
    func application() -> ApplicationCoordinatorAssemblyProtocol
    func editor() -> EditorCoordinatorAssemblyProtocol
    func editorSet() -> EditorSetCoordinatorAssemblyProtocol
    func editorPage() -> EditorPageCoordinatorAssemblyProtocol
    func setObjectCreationSettings() -> SetObjectCreationSettingsCoordinatorAssemblyProtocol
    func sharingTip() -> SharingTipCoordinatorProtocol
    
    // Now like a coordinator. Migrate to isolated modules
    func editorPageModule() -> EditorPageModuleAssemblyProtocol
}
