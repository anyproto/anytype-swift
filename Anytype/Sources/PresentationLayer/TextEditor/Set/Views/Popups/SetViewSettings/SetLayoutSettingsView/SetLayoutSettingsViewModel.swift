import SwiftUI
import Services
import Combine

@MainActor
final class SetLayoutSettingsViewModel: ObservableObject {
    @Published var types: [SetViewTypeConfiguration] = []
    
    private let setDocument: SetDocumentProtocol
    
    private var activeView: DataviewView = .empty
    private var selectedType: DataviewViewType = .table {
        didSet {
            updateTypes()
        }
    }
    private var cancellable: Cancellable?
    private let dataviewService: DataviewServiceProtocol
    
    init(setDocument: SetDocumentProtocol, dataviewService: DataviewServiceProtocol) {
        self.setDocument = setDocument
        self.dataviewService = dataviewService
        self.setupSubscription()
    }
    
    private func setupSubscription() {
        cancellable = setDocument.activeViewPublisher.sink { [weak self] activeView in
            guard let self else { return }
            self.activeView = activeView
            self.selectedType = activeView.type
        }
    }
    
    private func updateTypes() {
        types = DataviewViewType.allCases.compactMap { viewType in
            guard viewType.isSupported else { return nil }
            return SetViewTypeConfiguration(
                id: viewType.name,
                icon: viewType.icon,
                name: viewType.name,
                isSelected: viewType == selectedType,
                onTap: { [weak self] in
                    self?.selectedType = viewType
                    self?.updateView()
                }
            )
        }
    }
    
    private func updateView() {
        let newView = activeView.updated(
            type: selectedType
        )
        if activeView.type != selectedType {
            AnytypeAnalytics.instance().logChangeViewType(type: selectedType.stringValue, objectType: setDocument.analyticsType)
        }
        Task {
            try await dataviewService.updateView(newView)
        }
    }
}
