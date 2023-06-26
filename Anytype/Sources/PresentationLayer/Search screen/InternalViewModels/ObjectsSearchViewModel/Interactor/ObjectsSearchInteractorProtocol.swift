import Foundation
import Services

protocol ObjectsSearchInteractorProtocol {
    func search(text: String) async throws -> [ObjectDetails]
}
