import SwiftUI
import Combine

@MainActor
final class SetViewSettingsListModel: ObservableObject {
    @Published var name = ""
    @Published var focused = false
    @Published var layoutValue = SetViewSettings.layout.placeholder
    @Published var filtersValue = SetViewSettings.filters.placeholder
    @Published var sortsValue = SetViewSettings.sorts.placeholder
    
    let settings = SetViewSettings.allCases
    let canBeDeleted: Bool
    
    private let setDocument: SetDocumentProtocol
    private let dataviewService: DataviewServiceProtocol
    private weak var output: SetViewSettingsCoordinatorOutput?
    
    private var cancellables = [AnyCancellable]()
    
    init(
        setDocument: SetDocumentProtocol,
        dataviewService: DataviewServiceProtocol,
        output: SetViewSettingsCoordinatorOutput?
    ) {
        self.setDocument = setDocument
        self.dataviewService = dataviewService
        self.canBeDeleted = setDocument.dataView.views.count > 1
        self.output = output
        self.debounceNameChanges()
        self.setupSubscriptions()
    }
    
    func onSettingTap(_ setting: SetViewSettings) {
        switch setting {
        case .defaultObject:
            output?.onDefaultObjectTap()
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
        case .filters:
            return filtersValue
        case .sorts:
            return sortsValue
        default:
            return setting.placeholder
        }
    }
    
    func deleteView() {
        let activeView = setDocument.activeView
        Task {
            try await dataviewService.deleteView(activeView.id)
            AnytypeAnalytics.instance().logRemoveView(objectType: setDocument.analyticsType)
        }
    }
    
    func duplicateView() {
        let activeView = setDocument.activeView
        let source = setDocument.details?.setOf ?? []
        Task {
            try await dataviewService.createView(activeView, source: source)
            AnytypeAnalytics.instance().logDuplicateView(
                type: activeView.type.stringValue,
                objectType: setDocument.analyticsType
            )
        }
    }
    
    private func setupSubscriptions() {
        setDocument.activeViewPublisher.sink { [weak self] activeView in
            self?.name = activeView.name
            self?.layoutValue = activeView.type.name
        }.store(in: &cancellables)
        
        setDocument.filtersPublisher.sink { [weak self] filters in
            self?.updateFltersValue(filters)
        }.store(in: &cancellables)
        
        setDocument.sortsPublisher.sink { [weak self] sorts in
            self?.updateSortsValue(sorts)
        }.store(in: &cancellables)
    }
    
    private func debounceNameChanges() {
        $name
            .debounce(for: .seconds(0.5), scheduler: RunLoop.main)
            .filter { [weak self] name in
                self?.setDocument.activeView.name != name
            }
            .sink { [weak self] name in
                self?.updateView(with: name)
            }
            .store(in: &cancellables)
    }
    
    private func updateView(with name: String) {
        let newView = setDocument.activeView.updated(
            name: name
        )
        Task {
            try await dataviewService.updateView(newView)
        }
    }
    
    private func updateFltersValue(_ filters: [SetFilter]) {
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
