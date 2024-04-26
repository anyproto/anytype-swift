import SwiftUI
import Services

protocol SetSortsListCoordinatorAssemblyProtocol {
    @MainActor
    func make(with setDocument: SetDocumentProtocol, viewId: String) -> AnyView
}

final class SetSortsListCoordinatorAssembly: SetSortsListCoordinatorAssemblyProtocol {
    
    private let modulesDI: ModulesDIProtocol
    
    init(modulesDI: ModulesDIProtocol) {
        self.modulesDI = modulesDI
    }
    
    // MARK: - SetSortsListCoordinatorAssemblyProtocol
    
    @MainActor
    func make(with setDocument: SetDocumentProtocol, viewId: String) -> AnyView {
        return SetSortsListCoordinatorView(
            model: SetSortsListCoordinatorViewModel(
                setDocument: setDocument,
                viewId: viewId,
                setSortsListModuleAssembly: self.modulesDI.setSortsList(),
                newSearchModuleAssembly: self.modulesDI.newSearch(),
                setSortTypesListModuleAssembly: self.modulesDI.setSortTypesList()
            )
        ).eraseToAnyView()
    }
}
