import SwiftUI
import Combine
import ProtobufMessages


class ProfileNameViewModel: ObservableObject, Identifiable {
    var id: String
    @Published var image: UIImage? = nil
    @Published var color: UIColor?
    @Published var name: String = ""
    @Published var peers: String?
    
    init(id: String) {
        self.id = id
    }
    
    var userIcon: UserIconView.IconType {
        if let image = image {
            return UserIconView.IconType.image(.image(image))
        } else if let firstCharacter = name.first {
            return UserIconView.IconType.placeholder(firstCharacter)
        } else {
            return UserIconView.IconType.placeholder(nil)
        }
    }
}


class SelectProfileViewModel: ObservableObject {
    private let authService  = ServiceLocator.shared.authService()
    private let fileService = ServiceLocator.shared.fileService()
    
    private var cancellable: AnyCancellable?
    
    @Published var profilesViewModels = [ProfileNameViewModel]()
    @Published var error: String? {
        didSet {
            showError = false
            
            if error.isNotNil {
                showError = true
            }
        }
    }
    @Published var showError: Bool = false
    
    func accountRecover() {
        DispatchQueue.global().async { [weak self] in
            self?.handleAccountShowEvent()
            if let error = self?.authService.accountRecover() {
                DispatchQueue.main.async {
                    self?.error = error.localizedDescription
                }
            }
        }
    }
    
    func selectProfile(id: String) {
        if authService.selectAccount(id: id) {
            showHomeView()
        } else {
            self.error = "Select account error".localized
        }
    }
    
    // MARK: - Private func
    
    private func handleAccountShowEvent() {
        cancellable = NotificationCenter.Publisher(
            center: .default,
            name: .middlewareEvent,
            object: nil
        )
            .compactMap { $0.object as? EventsBunch }
            .map(\.middlewareEvents)
            .map {
                $0.filter { message in
                    guard let value = message.value else { return false }
                    
                    if case Anytype_Event.Message.OneOf_Value.accountShow = value {
                        return true
                    }
                    return false
                }
            }
            .filter { $0.count > 0 } 
            .receiveOnMain()
            .sink { [weak self] events in
                guard let self = self else {
                    return
                }
                
                self.selectProfile(id: events[0].accountShow.account.id)
            }
    }
    
    func showHomeView() {
        let homeAssembly = HomeViewAssembly()
        windowHolder?.startNewRootView(homeAssembly.createHomeView())
    }
}
