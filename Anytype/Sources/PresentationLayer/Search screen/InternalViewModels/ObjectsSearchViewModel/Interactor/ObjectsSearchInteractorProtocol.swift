import Foundation
import Services

@MainActor
protocol ObjectsSearchInteractorProtocol {
    func search(text: String) async throws -> [ObjectDetails]
}
