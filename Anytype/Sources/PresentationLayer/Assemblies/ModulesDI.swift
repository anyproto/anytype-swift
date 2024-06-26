import Foundation

extension Container {

    var legacyCreateObjectModuleAssembly: Factory<any CreateObjectModuleAssemblyProtocol> {
        self { CreateObjectModuleAssembly() }
    }
    
    var legacyEditorPageModuleAssembly: Factory<any EditorPageModuleAssemblyProtocol> {
        self { EditorPageModuleAssembly() }
    }
}
