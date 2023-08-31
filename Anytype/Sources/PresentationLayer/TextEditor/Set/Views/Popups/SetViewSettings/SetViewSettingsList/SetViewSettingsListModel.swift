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
    
    private let setDocument: SetDocumentProtocol
    private weak var output: SetViewSettingsCoordinatorOutput?
    
    private var cancellables = [AnyCancellable]()
    
    init(
        setDocument: SetDocumentProtocol,
        output: SetViewSettingsCoordinatorOutput?
    ) {
        self.setDocument = setDocument
        self.output = output
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

    }
    
    func duplicateView() {

    }
    
    private func setupSubscriptions() {
        setDocument.activeViewPublisher.sink { [weak self] activeView in
            self?.layoutValue = activeView.type.name
        }.store(in: &cancellables)
        
        setDocument.filtersPublisher.sink { [weak self] filters in
            self?.updateFltersValue(filters)
        }.store(in: &cancellables)
        
        setDocument.sortsPublisher.sink { [weak self] sorts in
            self?.updateSortsValue(sorts)
        }.store(in: &cancellables)
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
