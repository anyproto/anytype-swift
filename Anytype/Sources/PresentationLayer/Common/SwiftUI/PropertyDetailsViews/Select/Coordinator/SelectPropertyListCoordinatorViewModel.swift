import Foundation
import SwiftUI

@MainActor
final class SelectPropertyListCoordinatorViewModel: ObservableObject, SelectPropertyListModuleOutput {

    let data: SelectPropertyListData

    @Published var propertyData: PropertyData?
    @Published var deletionAlertData: DeletionAlertData?
    @Published var dismiss = false
    
    init(data: SelectPropertyListData) {
        self.data = data
    }

    // MARK: - SelectPropertyListModuleOutput
    
    func onClose() {
        dismiss.toggle()
    }
    
    func onCreateTap(text: String?, color: Color?, completion: @escaping (_ option: SelectPropertyOption) -> Void) {
        propertyData = PropertyData(
            configuration: PropertyOptionSettingsConfiguration(
                option: PropertyOptionParameters(
                    text: text,
                    color: color
                ),
                mode: .create(
                    PropertyOptionSettingsMode.CreateData(
                        relationKey: data.configuration.relationKey,
                        spaceId: data.configuration.spaceId
                    )
                )
            ),
            completion: { [weak self] optionParams in
                completion(SelectPropertyOption(optionParams: optionParams))
                self?.propertyData = nil
            }
        )
    }
    
    func onEditTap(option: SelectPropertyOption, completion: @escaping (_ option: SelectPropertyOption) -> Void) {
        propertyData = PropertyData(
            configuration: PropertyOptionSettingsConfiguration(
                option: PropertyOptionParameters(
                    id: option.id,
                    text: option.text,
                    color: option.color
                ),
                mode: .edit
            ),
            completion: { [weak self] optionParams in
                completion(SelectPropertyOption(optionParams: optionParams))
                self?.propertyData = nil
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
            icon: .Dialog.question
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

extension SelectPropertyListCoordinatorViewModel {
    struct PropertyData: Identifiable {
        let id = UUID()
        let configuration: PropertyOptionSettingsConfiguration
        let completion: (_ optionParams: PropertyOptionParameters) -> Void
    }
    
    struct DeletionAlertData: Identifiable {
        let id = UUID()
        let title: String
        let description: String
        let completion: (_ isSuccess: Bool) -> Void
    }
}
