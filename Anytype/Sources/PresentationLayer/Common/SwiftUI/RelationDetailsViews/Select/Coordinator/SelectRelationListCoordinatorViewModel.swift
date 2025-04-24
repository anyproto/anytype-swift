import Foundation
import SwiftUI

@MainActor
final class SelectRelationListCoordinatorViewModel: ObservableObject, SelectRelationListModuleOutput {

    let data: SelectRelationListData

    @Published var relationData: RelationData?
    @Published var deletionAlertData: DeletionAlertData?
    @Published var dismiss = false
    
    init(data: SelectRelationListData) {
        self.data = data
    }

    // MARK: - SelectRelationListModuleOutput
    
    func onClose() {
        dismiss.toggle()
    }
    
    func onCreateTap(text: String?, color: Color?, completion: @escaping (_ option: SelectRelationOption) -> Void) {
        relationData = RelationData(
            configuration: RelationOptionSettingsConfiguration(
                option: RelationOptionParameters(
                    text: text,
                    color: color
                ),
                mode: .create(
                    RelationOptionSettingsMode.CreateData(
                        relationKey: data.configuration.relationKey,
                        spaceId: data.configuration.spaceId
                    )
                )
            ),
            completion: { [weak self] optionParams in
                completion(SelectRelationOption(optionParams: optionParams))
                self?.relationData = nil
            }
        )
    }
    
    func onEditTap(option: SelectRelationOption, completion: @escaping (_ option: SelectRelationOption) -> Void) {
        relationData = RelationData(
            configuration: RelationOptionSettingsConfiguration(
                option: RelationOptionParameters(
                    id: option.id,
                    text: option.text,
                    color: option.color
                ),
                mode: .edit
            ),
            completion: { [weak self] optionParams in
                completion(SelectRelationOption(optionParams: optionParams))
                self?.relationData = nil
            }
        )
    }
    
    func onDeleteTap(completion: @escaping (_ isSuccess: Bool) -> Void) {
        deletionAlertData = DeletionAlertData(
            title: Loc.Relation.Delete.Alert.title,
            description: Loc.Relation.Delete.Alert.description,
            completion: completion
        )
    }
    
    func deletionAlertView(data: DeletionAlertData) -> AnyView {
        BottomAlertView(
            title: data.title,
            message: data.description,
            icon: .BottomAlert.question
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

extension SelectRelationListCoordinatorViewModel {
    struct RelationData: Identifiable {
        let id = UUID()
        let configuration: RelationOptionSettingsConfiguration
        let completion: (_ optionParams: RelationOptionParameters) -> Void
    }
    
    struct DeletionAlertData: Identifiable {
        let id = UUID()
        let title: String
        let description: String
        let completion: (_ isSuccess: Bool) -> Void
    }
}
