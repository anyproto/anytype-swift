import SwiftUI
import Combine
import Services

@MainActor
final class SetViewSettingsListModel: ObservableObject {
    @Published var name = ""
    @Published var layoutValue = SetViewSettings.layout.placeholder
    @Published var relationsValue = SetViewSettings.relations.placeholder
    @Published var filtersValue = SetViewSettings.filters.placeholder
    @Published var sortsValue = SetViewSettings.sorts.placeholder
    @Published var canEditSetView = false
    
    let settings = SetViewSettings.allCases
    
    let canBeDeleted: Bool
    
    let mode: SetViewSettingsMode
    
    private let setDocument: SetDocumentProtocol
    private let viewId: String
    
    @Injected(\.dataviewService)
    private var dataviewService: DataviewServiceProtocol
    
    private weak var output: SetViewSettingsCoordinatorOutput?
    
    private var cancellables = [AnyCancellable]()
    
    private var view: DataviewView = .empty
    
    init(
        data: SetSettingsData,
        output: SetViewSettingsCoordinatorOutput?
    ) {
        self.setDocument = data.setDocument
        self.viewId = data.viewId
        self.mode = data.mode
        self.output = output
        self.canBeDeleted = setDocument.dataView.views.count > 1
        self.debounceNameChanges()
        self.setupSubscriptions()
    }
    
    func shouldSetupFocus() -> Bool {
        mode == .new
    }
    
    func onSettingTap(_ setting: SetViewSettings) {
        switch setting {
        case .layout:
            output?.onLayoutTap()
        case .relations:
            output?.onRelationsTap()
        case .filters:
            output?.onFiltersTap()
        case .sorts:
            output?.onSortsTap()
        }
    }
    
    func valueForSetting(_ setting: SetViewSettings) -> String {
        switch setting {
        case .layout:
            return layoutValue
        case .relations:
            return relationsValue
        case .filters:
            return filtersValue
        case .sorts:
            return sortsValue
        }
    }
    
    func deleteView() {
        Task { [weak self] in
            guard let self else { return }
            try await dataviewService.deleteView(objectId: setDocument.objectId, blockId: setDocument.blockId, viewId: viewId)
            AnytypeAnalytics.instance().logRemoveView(objectType: setDocument.analyticsType)
        }
    }
    
    func duplicateView() {
        let source = setDocument.details?.setOf ?? []
        Task { [weak self] in
            guard let self else { return }
            try await dataviewService.createView(objectId: setDocument.objectId, blockId: setDocument.blockId, view: view, source: source)
            AnytypeAnalytics.instance().logDuplicateView(
                type: view.type.analyticStringValue,
                objectType: setDocument.analyticsType
            )
        }
    }
    
    private func setupSubscriptions() {
        setDocument.syncPublisher.sink { [weak self] in
            self?.updateState()
        }.store(in: &cancellables)
    }
    
    private func updateState() {
        view = setDocument.view(by: viewId)
        
        name = view.name
        layoutValue = view.type.isSupported ? view.type.name : Loc.EditorSet.View.Not.Supported.title
        canEditSetView = setDocument.setPermissions.canEditView
        updateRelationsValue()
        
        let sorts = setDocument.sorts(for: viewId)
        updateSortsValue(sorts)
        
        let filters = setDocument.filters(for: viewId)
        updateFiltersValue(filters)
    }
    
    private func debounceNameChanges() {
        $name
            .debounce(for: .seconds(0.5), scheduler: RunLoop.main)
            .filter { [weak self] name in
                self?.view.name != name
            }
            .sink { [weak self] name in
                self?.updateView(with: name)
            }
            .store(in: &cancellables)
    }
    
    private func updateView(with name: String) {
        let newView = view.updated(name: name)
        Task {
            try await dataviewService.updateView(objectId: setDocument.objectId, blockId: setDocument.blockId, view: newView)
        }
    }
    
    private func updateRelationsValue() {
        let visibleRelations = setDocument.sortedRelations(for: viewId).filter { $0.option.isVisible }
        let value = updatedValue(count: visibleRelations.count, firstName: visibleRelations.first?.relationDetails.name)
        relationsValue = value ?? SetViewSettings.relations.placeholder
    }
    
    private func updateFiltersValue(_ filters: [SetFilter]) {
        let value = updatedValue(count: filters.count, firstName: filters.first?.relationDetails.name)
        filtersValue = value ?? SetViewSettings.filters.placeholder
    }
    
    private func updateSortsValue(_ sorts: [SetSort]) {
        let value = updatedValue(count: sorts.count, firstName: sorts.first?.relationDetails.name)
        sortsValue = value ?? SetViewSettings.sorts.placeholder
    }
    
    private func updatedValue(count: Int, firstName: String?) -> String? {
        if count == 1, let firstName {
            return firstName
        } else if count > 1 {
            return Loc.Set.View.Settings.Objects.Applied.title(count)
        } else {
            return nil
        }
    }
}
