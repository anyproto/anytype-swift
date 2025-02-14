import Foundation
import Combine
import Services

class SetHeaderSettingsViewModel: ObservableObject {
    @Published var viewName = ""
    @Published var isActiveCreateButton = true
    @Published var isActiveHeader = true
    @Published var showUnsupportedBanner = false
    private let setDocument: any SetDocumentProtocol
    private var subscriptions = [AnyCancellable]()
    
    let onViewTap: () -> Void
    let onAITap: () -> Void
    let onSettingsTap: () -> Void
    let onCreateTap: () -> Void
    let onSecondaryCreateTap: () -> Void
    
    init(
        setDocument: some SetDocumentProtocol,
        onViewTap: @escaping () -> Void,
        onAITap: @escaping () -> Void,
        onSettingsTap: @escaping () -> Void,
        onCreateTap: @escaping () -> Void,
        onSecondaryCreateTap: @escaping () -> Void
    ) {
        self.setDocument = setDocument
        self.onViewTap = onViewTap
        self.onAITap = onAITap
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
        
        setDocument.syncPublisher
            .receiveOnMain()
            .sink { [weak self, weak setDocument] details in
                guard let self, let setDocument else { return }
                
                isActiveCreateButton = setDocument.setPermissions.canCreateObject
                isActiveHeader = setDocument.isActiveHeader()
                showUnsupportedBanner = !setDocument.activeView.type.isSupportedOnDevice
            }
            .store(in: &subscriptions)
    }
}
