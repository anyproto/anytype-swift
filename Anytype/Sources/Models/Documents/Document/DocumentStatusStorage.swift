import Foundation
import AnytypeCore
import Services

protocol DocumentStatusStorageProtocol: AnyObject {
    var status: SyncStatus { get set }
}

final class DocumentStatusStorage: DocumentStatusStorageProtocol {
    
    @Atomic
    var status: SyncStatus = .unknown
}
