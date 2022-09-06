import SwiftUI
import BlocksModels
import Combine

final class EditorSetViewPickerViewModel: ObservableObject {
    @Published var rows: [EditorSetViewRowConfiguration] = []
    
    private let setModel: EditorSetViewModel
    private var cancellable: AnyCancellable?
    
    private let router: EditorRouterProtocol
    private let dataviewService: DataviewServiceProtocol
    
    init(setModel: EditorSetViewModel, dataviewService: DataviewServiceProtocol, router: EditorRouterProtocol) {
        self.dataviewService = dataviewService
        self.router = router
        self.setModel = setModel
        self.cancellable = setModel.$dataView.sink { [weak self] dataView in
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
    }
    
    private func handleTap(with id: String) {
        setModel.updateActiveViewId(id)
    }
    
    private func handleEditTap(with id: String) {
        guard let activeView = setModel.dataView.views.first(where: { $0.id == id }) else {
            return
        }
        router.showViewTypes(activeView: activeView, dataviewService: dataviewService)
    }
}
