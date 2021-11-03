import Combine
import Foundation
import UIKit
import BlocksModels
import AnytypeCore

final class AccountInfoDataAccessor: ObservableObject {
    
    @Published private(set) var profileBlockId: BlockId
    @Published private(set) var name: String?
    @Published private(set) var avatarId: String?
    private lazy var cancellables = [AnyCancellable]()
    
    private let document: BaseDocumentProtocol
        
    init() {
        let blockId = MiddlewareConfigurationService.shared.configuration().profileBlockId
        profileBlockId = blockId
        document = BaseDocument(objectId: blockId)

        document.updatePublisher.sink { [weak self] in
            self?.handleDocumentUpdate($0)
        }.store(in: &cancellables)

        _ = document.open()
    }
    
    private func handleDocumentUpdate(_ update: EventsListenerUpdate) {
        switch update {
        case .general:
            updateAccountInfoData(details: document.objectDetails)
        case let .details(id: id):
            guard id == document.objectId else { return }
            
            updateAccountInfoData(details: document.objectDetails)
        case .blocks:
            return
        case .syncStatus:
            return
        }
    }
    
    private func updateAccountInfoData(details: ObjectDetails?) {
        guard let details = details else { return }
        
        self.name = details.name.isEmpty ? Constants.defaultName : details.name
        self.avatarId = details.iconImageHash?.value
    }
    
}

private extension AccountInfoDataAccessor {
    
    enum Constants {
        static let defaultName = "Anytype User"
    }
    
}
