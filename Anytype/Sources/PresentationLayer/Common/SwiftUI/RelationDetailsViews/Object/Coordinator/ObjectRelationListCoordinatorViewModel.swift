import Foundation
import SwiftUI
import Services

@MainActor
protocol ObjectRelationListCoordinatorModuleOutput: AnyObject {
    func onObjectOpen(screenData: EditorScreenData)
}

enum ObjectRelationListMode {
    case object(limitedObjectTypes: [String])
    case file
}

@MainActor
final class ObjectRelationListCoordinatorViewModel: ObservableObject, ObjectRelationListModuleOutput {

    let mode: ObjectRelationListMode
    let configuration: RelationModuleConfiguration
    let selectedOptionsIds: [String]
    
    private weak var output: ObjectRelationListCoordinatorModuleOutput?
    
    @Injected(\.objectTypeProvider)
    private var objectTypeProvider: ObjectTypeProviderProtocol
    
    @Published var deletionAlertData: DeletionAlertData?
    @Published var dismiss = false
    
    init(
        mode: ObjectRelationListMode,
        configuration: RelationModuleConfiguration,
        selectedOptionsIds: [String],
        output: ObjectRelationListCoordinatorModuleOutput?
    ) {
        self.mode = mode
        self.configuration = configuration
        self.selectedOptionsIds = selectedOptionsIds
        self.output = output
    }
    
    func obtainLimitedObjectTypes(with typesIds: [String]) -> [ObjectType] {
        typesIds.compactMap { [weak self] id in
            self?.objectTypeProvider.objectTypes.first { $0.id == id }
        }
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
            color: .red
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
