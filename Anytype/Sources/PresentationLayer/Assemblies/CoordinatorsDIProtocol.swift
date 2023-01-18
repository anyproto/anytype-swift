import Foundation

protocol CoordinatorsDIProtocol: AnyObject {
    var relationValue: RelationValueCoordinatorAssemblyProtocol { get }
    var templates: TemplatesCoordinatorAssemblyProtocol { get }
    var editorPage: EditorPageCoordinatorAssemblyProtocol { get }
    var linkToObject: LinkToObjectCoordinatorAssemblyProtocol { get }
    var objectSettings: ObjectSettingsCoordinatorAssemblyProtocol { get }
    var addNewRelation: AddNewRelationCoordinatorAssemblyProtocol { get }
    @MainActor
    var homeWidgets: HomeWidgetsCoordinatorAssemblyProtocol { get }
    
    // Rename
    @MainActor
    var application: ApplicationCoordinator { get }
    // Split to modules
    @MainActor
    var windowManager: WindowManager { get }
    
    // Now like a coordinator. Migrate to isolated modules
    var browser: EditorBrowserAssembly { get }
    var editor: EditorAssembly { get }
    var homeViewAssemby: HomeViewAssembly { get }
}
