import SwiftUI
import BlocksModels
import Combine

final class SetViewTypesPickerViewModel: ObservableObject {
    @Published var types: [SetViewTypeConfiguration] = []
    
    private let setModel: EditorSetViewModel
    private var cancellable: AnyCancellable?
    
    private var selectedType: DataviewViewType = .table
    private let completion: (DataviewViewType) -> Void
    
    init(setModel: EditorSetViewModel, completion: @escaping (DataviewViewType) -> Void){
        self.setModel = setModel
        self.selectedType = setModel.activeView.type
        self.completion = completion
        self.cancellable = setModel.$dataView.sink { [weak self] _ in
            self?.updateTypes()
        }
    }
    
    func buttonTapped() {
        completion(selectedType)
    }
    
    private func updateTypes() {
        types = DataviewViewType.allCases.map { viewType in
            SetViewTypeConfiguration(
                id: viewType.name,
                icon: viewType.icon,
                name: viewType.name,
                isSupported: viewType.isSupported,
                isSelected: viewType == selectedType,
                onTap: { [weak self] in
                    self?.handleTap(with: viewType)
                }
            )
        }
    }
    
    private func handleTap(with type: DataviewViewType) {
        selectedType = type
        updateTypes()
    }
}
