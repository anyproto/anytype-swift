import Foundation

extension Container {

    var legacyCreateObjectModuleAssembly: Factory<CreateObjectModuleAssemblyProtocol> {
        self { CreateObjectModuleAssembly() }
    }
    
    var legacyEditorPageModuleAssembly: Factory<EditorPageModuleAssemblyProtocol> {
        self { EditorPageModuleAssembly() }
    }
}
