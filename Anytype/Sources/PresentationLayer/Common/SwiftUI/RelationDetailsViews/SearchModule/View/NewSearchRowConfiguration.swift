import Foundation
import SwiftUI

struct NewSearchRowConfiguration: Hashable, Identifiable {
    
    let id: String
    @ViewBuilder
    let rowBuilder: () -> AnyView
    
    private let rowContentHash: Int
    
    init(id: String, rowContentHash: Int, @ViewBuilder row: @escaping () -> AnyView) {
        self.id = id
        self.rowContentHash = rowContentHash
        self.rowBuilder = row
    }
   
}

extension NewSearchRowConfiguration {
    
    var hashValue: Int { id.hashValue + rowContentHash }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(rowContentHash)
    }
    
    static func == (lhs: NewSearchRowConfiguration, rhs: NewSearchRowConfiguration) -> Bool {
        lhs.id == lhs.id && lhs.rowContentHash == rhs.rowContentHash
    }
    
}
