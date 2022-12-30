import SwiftUI
import BlocksModels

final class SetViewTypesPickerViewModel: ObservableObject {
    @Published var name = ""
    @Published var types: [SetViewTypeConfiguration] = []
    let canDelete: Bool
    
    var hasActiveView: Bool {
        activeView.isNotNil
    }
    
    private let dataView: BlockDataview
    private let activeView: DataviewView?
    private var selectedType: DataviewViewType = .table
    private let source: [String]
    private let dataviewService: DataviewServiceProtocol
    private let relationDetailsStorage: RelationDetailsStorageProtocol
    
    init(
        dataView: BlockDataview,
        activeView: DataviewView?,
        source: [String],
        dataviewService: DataviewServiceProtocol,
        relationDetailsStorage: RelationDetailsStorageProtocol)
    {
        self.dataView = dataView
        self.name = activeView?.name ?? ""
        self.activeView = activeView
        self.canDelete = dataView.views.count > 1
        self.selectedType = activeView?.type ?? .table
        self.source = source
        self.dataviewService = dataviewService
        self.relationDetailsStorage = relationDetailsStorage
        self.updateTypes()
    }
    
    func buttonTapped() {
        if let activeView = activeView {
            updateView(activeView: activeView)
        } else {
            createView()
        }
    }
    
    func deleteView() {
        guard let activeView = activeView else { return }
        Task {
            try await dataviewService.deleteView(activeView.id)
        }
    }
    
    func duplicateView() {
        guard let activeView = activeView else { return }
        Task {
            try await dataviewService.createView(activeView, source: source)
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
    
    private func updateView(activeView: DataviewView) {
        guard activeView.type != selectedType || activeView.name != name else {
            return
        }
        let dataViewRelationsDetails = relationDetailsStorage.relationsDetails(for: dataView.relationLinks)
        let groupRelationKey = activeView.groupRelationKey.isEmpty ?
        dataView.groupByRelations(for: activeView, dataViewRelationsDetails: dataViewRelationsDetails).first?.key ?? "" :
        activeView.groupRelationKey
        let newView = activeView.updated(
            name: name,
            type: selectedType,
            groupRelationKey: groupRelationKey
        )
        Task {
            try await dataviewService.updateView(newView)
        }
    }
    
    private func createView() {
        let name = name.isEmpty ? Loc.SetViewTypesPicker.Settings.Textfield.Placeholder.untitled : name
        Task {
            try await dataviewService.createView(
                DataviewView.created(with: name, type: selectedType),
                source: source
            )
        }
    }
    
    private func handleTap(with type: DataviewViewType) {
        selectedType = type
        updateTypes()
    }
}
