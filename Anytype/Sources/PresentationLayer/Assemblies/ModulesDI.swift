import Foundation

extension Container {

    var legacyCreateObjectModuleAssembly: Factory<CreateObjectModuleAssemblyProtocol> {
        self { CreateObjectModuleAssembly() }
    }
}
