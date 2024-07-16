import Services
import SwiftUI

struct VersionHistoryData: Identifiable {
    let document: any BaseDocumentProtocol
    var id: String { document.objectId }
}

@MainActor
final class VersionHistoryViewModel: ObservableObject {
    
    private let document: any BaseDocumentProtocol
    
    init(data: VersionHistoryData) {
        self.document = data.document
    }
}
