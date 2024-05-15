import Foundation
import UIKit
import Services
import AnytypeCore
import SecureService
import SharedContentManager
import DeepLinks

// TODO: Migrate to ServicesDI
final class ServiceLocator {
    
    var documentsProvider: DocumentsProviderProtocol {
        Container.shared.documentsProvider()
    }
    
    // MARK: - Services
    
    func documentService() -> OpenedDocumentsProviderProtocol {
        Container.shared.documentService()
    }
}
