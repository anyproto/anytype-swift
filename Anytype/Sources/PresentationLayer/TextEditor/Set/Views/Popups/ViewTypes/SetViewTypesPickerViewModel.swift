import SwiftUI
import BlocksModels

final class SetViewTypesPickerViewModel: ObservableObject {
    @Published var name = ""
    @Published var types: [SetViewTypeConfiguration] = []
    let canDelete: Bool
    
    var hasActiveView: Bool {
        activeView.isNotNil
    }
    
    private let activeView: DataviewView?
    private var selectedType: DataviewViewType = .table
    private let dataviewService: DataviewServiceProtocol
    
    init(activeView: DataviewView?, canDelete: Bool, dataviewService: DataviewServiceProtocol) {
        self.name = activeView?.name ?? ""
        self.activeView = activeView
        self.canDelete = canDelete
        self.selectedType = activeView?.type ?? .table
        self.dataviewService = dataviewService
        self.updateTypes()
    }
    
    func buttonTapped(completion: () -> Void) {
        defer { completion() }
        if let activeView = activeView {
            updateView(activeView: activeView)
        } else {
            createView()
        }
    }
    
    func deleteView(completion: () -> Void) {
        guard let activeView = activeView else { return }
        dataviewService.deleteView(activeView.id)
        completion()
    }
    
    func duplicateView(completion: () -> Void) {
        guard let activeView = activeView else { return }
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
    
    private func updateView(activeView: DataviewView) {
        guard activeView.type != selectedType || activeView.name != name else {
            return
        }
        let newView = activeView.updated(
            name: name,
            type: selectedType
        )
        dataviewService.updateView(newView)
    }
    
    private func createView() {
        let name = name.isEmpty ? Loc.SetViewTypesPicker.Settings.Texfield.Placeholder.untitled : name
        dataviewService.createView(
            DataviewView.created(with: name, type: selectedType)
        )
    }
    
    private func handleTap(with type: DataviewViewType) {
        selectedType = type
        updateTypes()
    }
}
