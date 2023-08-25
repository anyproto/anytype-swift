import SwiftUI
import Combine

@MainActor
final class SetViewSettingsListModel: ObservableObject {
    @Published var name = ""
    @Published var focused = false
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
        setDocument.sortsPublisher.sink { [weak self] sorts in
            self?.updateSortsValue(sorts)
        }.store(in: &cancellables)
    }
    
    private func updateSortsValue(_ sorts: [SetSort]) {
        if sorts.count == 1, let sortName = sorts.first?.relationDetails.name {
            sortsValue = sortName
        } else if sorts.count > 1 {
            sortsValue = Loc.Set.View.Settings.Objects.Applied.title(sorts.count)
        } else {
            sortsValue = SetViewSettings.sorts.placeholder
        }
    }
}
