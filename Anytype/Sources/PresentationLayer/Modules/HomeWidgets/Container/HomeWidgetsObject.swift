import Foundation

protocol HomeWidgetsObjectProtocol: AnyObject {
    var baseDocument: BaseDocumentProtocol { get }
    
    @MainActor
    func open() async throws
    @MainActor
    func close() async throws
}

final class HomeWidgetsObject: HomeWidgetsObjectProtocol {
    
    let baseDocument: BaseDocumentProtocol
    
    init(objectId: String) {
        self.baseDocument = BaseDocument(objectId: objectId)
    }
    
    @MainActor
    func open() async throws {
        try await baseDocument.open()
    }
    
    @MainActor
    func close() async throws {
        try await baseDocument.close()
    }
}
