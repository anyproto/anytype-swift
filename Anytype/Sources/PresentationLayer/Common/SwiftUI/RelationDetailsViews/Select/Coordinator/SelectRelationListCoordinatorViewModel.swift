import Foundation
import SwiftUI

@MainActor
final class SelectRelationListCoordinatorViewModel: ObservableObject, SelectRelationListModuleOutput {

    private let objectId: String
    private let configuration: RelationModuleConfiguration
    private let selectedOption: SelectRelationOption?
    private let selectRelationListModuleAssembly: SelectRelationListModuleAssemblyProtocol
    private let selectRelationSettingsModuleAssembly: SelectRelationSettingsModuleAssemblyProtocol

    @Published var relationData: RelationData?
    @Published var deletionAlertData: DeletionAlertData?
    @Published var dismiss = false
    
    init(
        objectId: String,
        configuration: RelationModuleConfiguration,
        selectedOption: SelectRelationOption?,
        selectRelationListModuleAssembly: SelectRelationListModuleAssemblyProtocol,
        selectRelationSettingsModuleAssembly: SelectRelationSettingsModuleAssemblyProtocol
    ) {
        self.objectId = objectId
        self.configuration = configuration
        self.selectedOption = selectedOption
        self.selectRelationListModuleAssembly = selectRelationListModuleAssembly
        self.selectRelationSettingsModuleAssembly = selectRelationSettingsModuleAssembly
    }
    
    func selectRelationListModule() -> AnyView {
        selectRelationListModuleAssembly.make(
            objectId: objectId,
            configuration: configuration,
            selectedOption: selectedOption,
            output: self
        )
    }

    // MARK: - SelectRelationListModuleOutput
    
    func onClose() {
        dismiss.toggle()
    }
    
    func onCreateTap(text: String?, color: Color?, completion: @escaping (_ optionId: String) -> Void) {
        relationData = RelationData(
            text: text,
            color: color,
            mode: .create(RelationSettingsMode.CreateData(
                relationKey: configuration.relationKey,
                spaceId: configuration.spaceId
            )),
            completion: { [weak self] optionId in
                completion(optionId)
                self?.relationData = nil
            }
        )
    }
    
    func onEditTap(option: SelectRelationOption, completion: @escaping () -> Void) {
        relationData = RelationData(
            text: option.text,
            color: option.color,
            mode: .edit(option.id),
            completion: { [weak self] _ in
                completion()
                self?.relationData = nil
            }
        )
    }
    
    func selectRelationCreate(data: RelationData) -> AnyView {
        selectRelationSettingsModuleAssembly.make(
            text: data.text,
            color: data.color,
            mode: data.mode,
            objectId: objectId,
            completion: data.completion
        )
    }
    
    func onDeleteTap(completion: @escaping (_ isSuccess: Bool) -> Void) {
        deletionAlertData = DeletionAlertData(
            title: Loc.Relation.Delete.Alert.title,
            description: Loc.Relation.Delete.Alert.description,
            completion: { [weak self] isSuccess in
                completion(isSuccess)
                self?.deletionAlertData = nil
            }
        )
    }
    
    func deletionAlertView(data: DeletionAlertData) -> AnyView {
        BottomAlertView(
            title: data.title,
            message: data.description,
            icon: .BottomAlert.question,
            style: .red
        ) {
            BottomAlertButton(text: Loc.cancel, style: .secondary) {
                data.completion(false)
            }
            BottomAlertButton(text: Loc.delete, style: .warning) {
                data.completion(true)
            }
        }.eraseToAnyView()
    }
}

extension SelectRelationListCoordinatorViewModel {
    struct RelationData: Identifiable {
        let id = UUID()
        let text: String?
        let color: Color?
        let mode: RelationSettingsMode
        let completion: (_ optionId: String) -> Void
    }
    
    struct DeletionAlertData: Identifiable {
        let id = UUID()
        let title: String
        let description: String
        let completion: (_ isSuccess: Bool) -> Void
    }
}
