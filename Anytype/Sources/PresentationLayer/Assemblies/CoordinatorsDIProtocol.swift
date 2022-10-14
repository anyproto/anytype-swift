import Foundation

protocol CoordinatorsDIProtocol: AnyObject {
    var relationValue: RelationValueCoordinatorAssemblyProtocol { get }
    var templates: TemplatesCoordinatorAssemblyProtocol { get }
    var editorPage: EditorPageCoordinatorAssemblyProtocol { get }
    var linkInText: LinkInTextCoordinatorAssemblyProtocol { get }
    
    // Now like a coordinator. Migrate to isolated modules
    var browser: EditorBrowserAssembly { get }
    var editor: EditorAssembly { get }
    var homeViewAssemby: HomeViewAssembly { get }
}
