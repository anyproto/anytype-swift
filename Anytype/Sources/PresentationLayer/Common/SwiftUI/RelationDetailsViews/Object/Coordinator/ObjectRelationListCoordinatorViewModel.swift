import Foundation
import SwiftUI

@MainActor
protocol ObjectRelationListCoordinatorModuleOutput: AnyObject {
    func onObjectOpen(screenData: EditorScreenData)
}

@MainActor
final class ObjectRelationListCoordinatorViewModel: ObservableObject, ObjectRelationListModuleOutput {

    private let objectId: String
    private let configuration: RelationModuleConfiguration
    private let limitedObjectTypes: [String]
    private let selectedOptionsIds: [String]
    private let objectRelationListModuleAssembly: ObjectRelationListModuleAssemblyProtocol
    private weak var output: ObjectRelationListCoordinatorModuleOutput?
    
    @Published var deletionAlertData: DeletionAlertData?
    @Published var dismiss = false
    
    init(
        objectId: String,
        configuration: RelationModuleConfiguration,
        limitedObjectTypes: [String],
        selectedOptionsIds: [String],
        objectRelationListModuleAssembly: ObjectRelationListModuleAssemblyProtocol,
        output: ObjectRelationListCoordinatorModuleOutput?
    ) {
        self.objectId = objectId
        self.configuration = configuration
        self.limitedObjectTypes = limitedObjectTypes
        self.selectedOptionsIds = selectedOptionsIds
        self.objectRelationListModuleAssembly = objectRelationListModuleAssembly
        self.output = output
    }
    
    func objectRelationListModule() -> AnyView {
        objectRelationListModuleAssembly.make(
            objectId: objectId,
            limitedObjectTypes: limitedObjectTypes,
            configuration: configuration,
            selectedOptionsIds: selectedOptionsIds,
            output: self
        )
    }

    // MARK: - ObjectRelationListModuleOutput
    
    func onClose() {
        dismiss.toggle()
    }
    
    func onObjectOpen(screenData: EditorScreenData?) {
        guard let screenData else { return }
        output?.onObjectOpen(screenData: screenData)
        onClose()
    }
    
    func onDeleteTap(completion: @escaping (_ isSuccess: Bool) -> Void) {
        deletionAlertData = DeletionAlertData(
            title: Loc.Relation.Delete.Alert.title,
            description: Loc.Relation.Object.Delete.Alert.description,
            completion: completion
        )
    }
    
    func deletionAlertView(data: DeletionAlertData) -> AnyView {
        BottomAlertView(
            title: data.title,
            message: data.description,
            icon: .BottomAlert.question,
            style: .red
        ) {
            BottomAlertButton(text: Loc.cancel, style: .secondary) { [weak self] in
                data.completion(false)
                self?.deletionAlertData = nil
            }
            BottomAlertButton(text: Loc.delete, style: .warning) { [weak self] in
                data.completion(true)
                self?.deletionAlertData = nil
            }
        }.eraseToAnyView()
    }
}

extension ObjectRelationListCoordinatorViewModel {
    struct DeletionAlertData: Identifiable {
        let id = UUID()
        let title: String
        let description: String
        let completion: (_ isSuccess: Bool) -> Void
    }
}
