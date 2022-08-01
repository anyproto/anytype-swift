import SwiftUI
import BlocksModels
import Combine

final class EditorSetViewPickerViewModel: ObservableObject {
    @Published var rows: [EditorSetViewRowConfiguration] = []
    
    private let setModel: EditorSetViewModel
    private var cancellable: AnyCancellable?
    
    init(setModel: EditorSetViewModel){
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
                typeName: view.type.name,
                isSupported: view.isSupported,
                isActive: view == setModel.activeView,
                onTap: { [weak self] in
                    self?.handleTap(with: view.id)
                }
            )
        }
    }
    
    private func handleTap(with id: String) {
        setModel.updateActiveViewId(id)
    }
}
