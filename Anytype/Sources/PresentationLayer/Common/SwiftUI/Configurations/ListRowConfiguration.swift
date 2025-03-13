import Foundation
import SwiftUI

struct ListRowConfiguration: Hashable, Identifiable {
    
    let id: String
    
    private let viewBuilder: @MainActor () -> AnyView
    private let contentHash: Int
    
    init(
        id: String,
        contentHash: Int,
        @ViewBuilder viewBuilder: @escaping @MainActor () -> AnyView
    ) {
        self.id = id
        self.contentHash = contentHash
        self.viewBuilder = viewBuilder
    }
    
    @MainActor
    func makeView() -> AnyView {
        viewBuilder()
    }
   
}

extension ListRowConfiguration {
    
    var hashValue: Int { id.hashValue + contentHash }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(contentHash)
    }
    
    static func == (lhs: ListRowConfiguration, rhs: ListRowConfiguration) -> Bool {
        lhs.id == lhs.id && lhs.contentHash == rhs.contentHash
    }
    
}
