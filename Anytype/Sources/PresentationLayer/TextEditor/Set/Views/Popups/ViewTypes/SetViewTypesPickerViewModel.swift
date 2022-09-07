import SwiftUI
import BlocksModels

final class SetViewTypesPickerViewModel: ObservableObject {
    @Published var types: [SetViewTypeConfiguration] = []
    
    private let activeView: DataviewView
    private var selectedType: DataviewViewType = .table
    private let dataviewService: DataviewServiceProtocol
    
    init(activeView: DataviewView, dataviewService: DataviewServiceProtocol) {
        self.activeView = activeView
        self.selectedType = activeView.type
        self.dataviewService = dataviewService
        self.updateTypes()
    }
    
    func buttonTapped(completion: () -> Void) {
        updateView(completion: completion)
    }
    
    func deleteView(completion: () -> Void) {
        dataviewService.deleteView(activeView.id)
        completion()
    }
    
    func duplicateView(completion: () -> Void) {
        dataviewService.createView(activeView)
        completion()
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
    
    private func updateView(completion: () -> Void) {
        let newView = activeView.updated(type: selectedType)
        dataviewService.updateView(newView)
        completion()
    }
    
    private func handleTap(with type: DataviewViewType) {
        selectedType = type
        updateTypes()
    }
}
