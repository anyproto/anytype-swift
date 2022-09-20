import SwiftUI
import BlocksModels

@MainActor
final class SetViewTypesPickerViewModel: ObservableObject {
    @Published var name = ""
    @Published var types: [SetViewTypeConfiguration] = []
    let canDelete: Bool
    
    private let activeView: DataviewView
    private var selectedType: DataviewViewType = .table
    private let dataviewService: DataviewServiceProtocol
    
    init(activeView: DataviewView, canDelete: Bool, dataviewService: DataviewServiceProtocol) {
        self.name = activeView.name
        self.activeView = activeView
        self.canDelete = canDelete
        self.selectedType = activeView.type
        self.dataviewService = dataviewService
        self.updateTypes()
    }
    
    func buttonTapped(completion: () -> Void) {
        updateView(completion: completion)
    }
    
    func deleteView(completion: @escaping () -> Void) {
        Task { @MainActor in
            try await dataviewService.deleteView(activeView.id)
            completion()
        }
    }
    
    func duplicateView(completion: @escaping () -> Void) {
        Task { @MainActor in
            try await dataviewService.createView(activeView)
            completion()
        }
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
        defer { completion() }
        guard activeView.type != selectedType || activeView.name != name else {
            return
        }
        let newView = activeView.updated(
            name: name,
            type: selectedType
        )
        dataviewService.updateView(newView)
    }
    
    private func handleTap(with type: DataviewViewType) {
        selectedType = type
        updateTypes()
    }
}
