import SwiftUI
import BlocksModels
import Combine
import AnytypeCore

@MainActor
final class EditorSetViewPickerViewModel: ObservableObject {
    @Published var rows: [EditorSetViewRowConfiguration] = []
    @Published var disableDeletion = false
    
    private let setModel: EditorSetViewModel
    private var cancellable: AnyCancellable?
    private let dataviewService: DataviewServiceProtocol
    private let showViewTypes: RoutingAction<DataviewView>
    
    init(
        setModel: EditorSetViewModel,
        dataviewService: DataviewServiceProtocol,
        showViewTypes: @escaping RoutingAction<DataviewView>)
    {
        self.setModel = setModel
        self.dataviewService = dataviewService
        self.showViewTypes = showViewTypes
        self.cancellable = setModel.$dataView.sink { [weak self] dataView in
            self?.updateRows(with: dataView)
        }
    }
    
    func move(from: IndexSet, to: Int) {
        from.forEach { viewFromIndex in
            guard viewFromIndex != to, viewFromIndex < setModel.dataView.views.count else { return }
            let view = setModel.dataView.views[viewFromIndex]
            let position = to > viewFromIndex ? to - 1 : to
            dataviewService.setPositionForView(view.id, position: position)
        }
    }
    
    func delete(_ indexSet: IndexSet) {
        Task { @MainActor in
            for deleteIndex in indexSet {
                guard deleteIndex < setModel.dataView.views.count else { return }
                let view = setModel.dataView.views[deleteIndex]
                try await dataviewService.deleteView(view.id)
            }
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
        setModel.updateActiveViewId(id)
    }
    
    private func handleEditTap(with id: String) {
        guard let activeView = setModel.dataView.views.first(where: { $0.id == id }) else {
            return
        }
        showViewTypes(activeView)
    }
}
