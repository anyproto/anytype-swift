import Foundation
import SwiftUI

struct NewSearchSectionConfiguration: Hashable, Identifiable {
    
    let id: String
    let title: String
    let rows: [NewSearchRowConfiguration]
    
}
