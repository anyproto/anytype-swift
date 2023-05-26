import SwiftUI
import Services

final class SetViewTypesPickerViewModel: ObservableObject {
    @Published var name = ""
    @Published var types: [SetViewTypeConfiguration] = []
    let canDelete: Bool
    
    var hasActiveView: Bool {
        activeView.isNotNil
    }
    
    private let setDocument: SetDocumentProtocol
    private let activeView: DataviewView?
    private var selectedType: DataviewViewType = .table
    private let source: [String]
    private let dataviewService: DataviewServiceProtocol
    private let relationDetailsStorage: RelationDetailsStorageProtocol
    
    init(
        setDocument: SetDocumentProtocol,
        activeView: DataviewView?,
        dataviewService: DataviewServiceProtocol,
        relationDetailsStorage: RelationDetailsStorageProtocol)
    {
        self.setDocument = setDocument
        self.name = activeView?.name ?? ""
        self.activeView = activeView
        self.canDelete = setDocument.dataView.views.count > 1
        self.selectedType = activeView?.type ?? .table
        self.source = setDocument.details?.setOf ?? []
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
            AnytypeAnalytics.instance().logRemoveView(objectType: setDocument.analyticsType)
        }
    }
    
    func duplicateView() {
        guard let activeView = activeView else { return }
        Task {
            try await dataviewService.createView(activeView, source: source)
            AnytypeAnalytics.instance().logDuplicateView(
                type: activeView.type.stringValue,
                objectType: setDocument.analyticsType
            )
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
        let dataViewRelationsDetails = relationDetailsStorage.relationsDetails(for: setDocument.dataView.relationLinks)
        let groupRelationKey = activeView.groupRelationKey.isEmpty ?
        setDocument.dataView.groupByRelations(for: activeView, dataViewRelationsDetails: dataViewRelationsDetails).first?.key ?? "" :
        activeView.groupRelationKey
        let newView = activeView.updated(
            name: name,
            type: selectedType,
            groupRelationKey: groupRelationKey
        )
        if activeView.type != selectedType {
            AnytypeAnalytics.instance().logChangeViewType(type: selectedType.stringValue, objectType: setDocument.analyticsType)
        }
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
            AnytypeAnalytics.instance().logAddView(type: selectedType.stringValue, objectType: setDocument.analyticsType)
        }
    }
    
    private func handleTap(with type: DataviewViewType) {
        selectedType = type
        updateTypes()
    }
}
