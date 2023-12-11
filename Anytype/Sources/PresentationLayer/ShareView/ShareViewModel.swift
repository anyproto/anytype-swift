import AnytypeCore
import Combine
import Services
import Foundation

@MainActor
final class ShareViewModel: ObservableObject {
    @Published var isSaveButtonAvailable = false
    
    var onClose: RoutingAction<Void>?
    
    private var sharedContentSaveOption: SharedContentSaveOption?
    
    let contentViewModel: ShareViewModelProtocol
    private let interactor: SharedContentInteractorProtocol
    private let contentManager: SharedContentManagerProtocol
    
    init(
        contentViewModel: ShareViewModelProtocol,
        interactor: SharedContentInteractorProtocol,
        contentManager: SharedContentManagerProtocol
    ) {
        self.contentViewModel = contentViewModel
        self.interactor = interactor
        self.contentManager = contentManager
        
        contentViewModel.onSaveOptionSave = { [weak self] option in
            self?.sharedContentSaveOption = option
            self?.isSaveButtonAvailable = option.isSaveButtonAvailable
        }
        
        if #available(iOS 17.0, *) {
            SharingTip().invalidate(reason: .actionPerformed)
        }
    }
    
    func tapClose() {
        contentManager.clearSharedContent()
        onClose?(())
    }
    
    func tapSave() {
        guard let option = sharedContentSaveOption else {
            return
        }
        Task {
            do {
                try await interactor.saveContent(saveOption: option)
                onClose?(())
            } catch {
                anytypeAssertionFailure("Can't save content: \(error) from sharing extension")
                onClose?(())
            }
            
            contentManager.clearSharedContent()
        }
    }
}

private extension SharedContentSaveOption {
    var isSaveButtonAvailable: Bool {
        switch self {
        case .unavailable: return false
        default: return true
        }
    }
}
