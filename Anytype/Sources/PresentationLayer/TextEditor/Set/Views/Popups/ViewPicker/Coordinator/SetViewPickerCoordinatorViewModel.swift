import SwiftUI
import Services
import AnytypeCore

@MainActor
protocol SetViewPickerCoordinatorOutput: AnyObject {
    func onAddButtonTap()
    func onEditButtonTap(dataView: DataviewView)
}

@MainActor
final class SetViewPickerCoordinatorViewModel: ObservableObject, SetViewPickerCoordinatorOutput {
    @Published var addRelationsData: AddRelationsData?
    
    private let setDocument: SetDocumentProtocol
    private let setViewPickerModuleAssembly: SetViewPickerModuleAssemblyProtocol
    private let showViewTypes: RoutingAction<DataviewView?>
    
    init(
        setDocument: SetDocumentProtocol,
        setViewPickerModuleAssembly: SetViewPickerModuleAssemblyProtocol,
        showViewTypes: @escaping RoutingAction<DataviewView?>
    ) {
        self.setDocument = setDocument
        self.setViewPickerModuleAssembly = setViewPickerModuleAssembly
        self.showViewTypes = showViewTypes
    }
    
    func list() -> AnyView {
        setViewPickerModuleAssembly.make(
            setDocument: setDocument,
            output: self
        )
    }
    
    // MARK: - SetViewPickerCoordinatorOutput
    
    func onAddButtonTap() {
        showViewTypes(nil)
    }
    
    func onEditButtonTap(dataView: DataviewView) {
        showViewTypes(dataView)
    }
}

extension SetViewPickerCoordinatorViewModel {
    struct AddRelationsData: Identifiable {
        let id = UUID()
        let completion: (RelationDetails, _ isNew: Bool) -> Void
    }
}
