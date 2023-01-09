import SwiftUI
import BlocksModels
import Combine
import AnytypeCore

final class EditorSetViewPickerViewModel: ObservableObject {
    @Published var rows: [EditorSetViewRowConfiguration] = []
    @Published var disableDeletion = false
    
    private let setDocument: SetDocumentProtocol
    private var cancellable: AnyCancellable?
    private let dataviewService: DataviewServiceProtocol
    private let showViewTypes: RoutingAction<DataviewView?>
    
    init(
        setDocument: SetDocumentProtocol,
        dataviewService: DataviewServiceProtocol,
        showViewTypes: @escaping RoutingAction<DataviewView?>)
    {
        self.setDocument = setDocument
        self.dataviewService = dataviewService
        self.showViewTypes = showViewTypes
        self.setup()
    }
    
    func addButtonTapped() {
        showViewTypes(nil)
    }
    
    func move(from: IndexSet, to: Int) {
        from.forEach { viewFromIndex in
            guard viewFromIndex != to, viewFromIndex < setDocument.dataView.views.count else { return }
            let view = setDocument.dataView.views[viewFromIndex]
            let position = to > viewFromIndex ? to - 1 : to
            Task {
                try await dataviewService.setPositionForView(view.id, position: position)
            }
        }
    }
    
    func delete(_ indexSet: IndexSet) {
        indexSet.forEach { deleteIndex in
            guard deleteIndex < setDocument.dataView.views.count else { return }
            let view = setDocument.dataView.views[deleteIndex]
            Task {
                try await dataviewService.deleteView(view.id)
            }
        }
    }
    
    private func setup() {
        cancellable = setDocument.dataviewPublisher.sink { [weak self] dataView in
            self?.updateRows(with: dataView)
        }
    }
    
    private func updateRows(with dataView: BlockDataview) {
        rows = dataView.views.map { view in
            EditorSetViewRowConfiguration(
                id: view.id,
                name: view.name,
                typeName: view.type.name.lowercased(),
                isSupported: view.type.isSupported,
                isActive: view == dataView.views.first { $0.id == dataView.activeViewId },
                onTap: { [weak self] in
                    self?.handleTap(with: view.id)
                },
                onEditTap: { [weak self] in
                    self?.handleEditTap(with: view.id)
                }
            )
        }
        disableDeletion = rows.count < 2
    }
    
    private func handleTap(with id: String) {
        setDocument.updateActiveViewId(id)
    }
    
    private func handleEditTap(with id: String) {
        guard let activeView = setDocument.dataView.views.first(where: { $0.id == id }) else {
            return
        }
        showViewTypes(activeView)
    }
}
