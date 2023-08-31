import Foundation
import Combine
import Services

class SetHeaderSettingsViewModel: ObservableObject {
    @Published var viewName = ""
    @Published var isActive = true
    @Published var isTemplatesSelectionAvailable = false
    
    private let setDocument: SetDocumentProtocol
    private let setTemplatesInteractor: SetTemplatesInteractorProtocol
    private var subscriptions = [AnyCancellable]()
    
    let onViewTap: () -> Void
    let onSettingsTap: () -> Void
    let onCreateTap: () -> Void
    let onSecondaryCreateTap: () -> Void
    
    init(
        setDocument: SetDocumentProtocol,
        setTemplatesInteractor: SetTemplatesInteractorProtocol,
        onViewTap: @escaping () -> Void,
        onSettingsTap: @escaping () -> Void,
        onCreateTap: @escaping () -> Void,
        onSecondaryCreateTap: @escaping () -> Void
    ) {
        self.setDocument = setDocument
        self.setTemplatesInteractor = setTemplatesInteractor
        self.onViewTap = onViewTap
        self.onSettingsTap = onSettingsTap
        self.onCreateTap = onCreateTap
        self.onSecondaryCreateTap = onSecondaryCreateTap
        self.setup()
    }
    
    private func setup() {
        setDocument.activeViewPublisher
            .sink { [weak self] view in
                guard let self else { return }
                viewName = view.name
                if setDocument.activeView.defaultObjectTypeID != view.defaultObjectTypeID {
                    checkTemplatesAvailablility(activeView: view)
                }
            }
            .store(in: &subscriptions)
        
        setDocument.detailsPublisher
            .sink { [weak self] details in
                guard let self else { return }
                isActive = details.setOf.first { $0.isNotEmpty } != nil || details.isCollection
                if setDocument.isCollection() || setDocument.isRelationsSet() {
                    checkTemplatesAvailablility(activeView: setDocument.activeView)
                } else {
                    checkTemplatesAvailablility(details: details)
                }
            }
            .store(in: &subscriptions)
    }
    
    func checkTemplatesAvailablility(activeView: DataviewView) {
        Task { @MainActor in
            let isTemplatesAvailable = try await setTemplatesInteractor.isTemplatesAvailableFor(
                activeView: activeView
            )
            isTemplatesSelectionAvailable = isTemplatesAvailable
        }
    }
    
    func checkTemplatesAvailablility(details: ObjectDetails) {
        Task { @MainActor in
            let isTemplatesAvailable = try await setTemplatesInteractor.isTemplatesAvailableFor(
                setObject: details
            )
            isTemplatesSelectionAvailable = isTemplatesAvailable
        }
    }
}
