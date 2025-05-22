import Foundation
import SwiftUI
import Services

@MainActor
protocol ObjectPropertyListCoordinatorModuleOutput: AnyObject {
    func onObjectOpen(screenData: ScreenData)
}

@MainActor
final class ObjectPropertyListCoordinatorViewModel: ObservableObject, ObjectPropertyListModuleOutput {

    let data: ObjectPropertyListData
    
    private weak var output: (any ObjectPropertyListCoordinatorModuleOutput)?
    
    @Injected(\.objectTypeProvider)
    private var objectTypeProvider: any ObjectTypeProviderProtocol
    
    @Published var deletionAlertData: DeletionAlertData?
    @Published var dismiss = false
    
    init(
        data: ObjectPropertyListData,
        output: (any ObjectPropertyListCoordinatorModuleOutput)?
    ) {
        self.data = data
        self.output = output
    }
    
    func obtainLimitedObjectTypes(with typesIds: [String]) -> [ObjectType] {
        typesIds.compactMap { try? objectTypeProvider.objectType(id: $0) }
    }

    // MARK: - ObjectPropertyListModuleOutput
    
    func onClose() {
        dismiss.toggle()
    }
    
    func onObjectOpen(screenData: ScreenData?) {
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

extension ObjectPropertyListCoordinatorViewModel {
    struct DeletionAlertData: Identifiable {
        let id = UUID()
        let title: String
        let description: String
        let completion: (_ isSuccess: Bool) -> Void
    }
}
