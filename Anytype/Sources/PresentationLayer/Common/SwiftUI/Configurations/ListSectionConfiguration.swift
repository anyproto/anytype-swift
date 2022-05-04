import Foundation
import SwiftUI

struct ListSectionConfiguration: Hashable, Identifiable {
    
    let id: String
    let title: String
    let rows: [ListRowConfiguration]
    
    func makeView() -> some View {
        RelationOptionsSectionHeaderView(title: title)
    }
    
}
