import Foundation
import Combine
import Services

@MainActor
@Observable
final class SetHeaderSettingsViewModel {
    var viewName = ""
    var isActiveCreateButton = true
    var isActiveHeader = true
    var showUnsupportedBanner = false
    @ObservationIgnored
    let setDocument: any SetDocumentProtocol
    @ObservationIgnored
    let output: (any ObjectSettingsCoordinatorOutput)?
    @ObservationIgnored
    private var subscriptions = [AnyCancellable]()

    @ObservationIgnored
    let onViewTap: () -> Void
    @ObservationIgnored
    let onSettingsTap: () -> Void
    @ObservationIgnored
    let onCreateTap: () -> Void
    @ObservationIgnored
    let onSecondaryCreateTap: () -> Void
    
    var isObjectType: Bool { setDocument.details?.isObjectType ?? false }
    
    init(
        setDocument: some SetDocumentProtocol,
        output: (any ObjectSettingsCoordinatorOutput)?,
        onViewTap: @escaping () -> Void,
        onSettingsTap: @escaping () -> Void,
        onCreateTap: @escaping () -> Void,
        onSecondaryCreateTap: @escaping () -> Void
    ) {
        self.setDocument = setDocument
        self.output = output
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
