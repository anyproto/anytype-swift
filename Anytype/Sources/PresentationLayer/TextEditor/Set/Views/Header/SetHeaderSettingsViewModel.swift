import Foundation
import Combine
import Services

class SetHeaderSettingsViewModel: ObservableObject {
    @Published var viewName = ""
    @Published var isActiveCreateButton = true
    @Published var isActiveHeader = true
    
    private let setDocument: SetDocumentProtocol
    private var subscriptions = [AnyCancellable]()
    
    let onViewTap: () -> Void
    let onSettingsTap: () -> Void
    let onCreateTap: () -> Void
    let onSecondaryCreateTap: () -> Void
    
    init(
        setDocument: SetDocumentProtocol,
        onViewTap: @escaping () -> Void,
        onSettingsTap: @escaping () -> Void,
        onCreateTap: @escaping () -> Void,
        onSecondaryCreateTap: @escaping () -> Void
    ) {
        self.setDocument = setDocument
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
            }
            .store(in: &subscriptions)
        
        setDocument.detailsPublisher
            .sink { [weak self, weak setDocument] details in
                guard let self, let setDocument else { return }
                
                isActiveCreateButton = setDocument.canCreateObject()
                isActiveHeader = setDocument.isActiveHeader()
            }
            .store(in: &subscriptions)
    }
}
