import SwiftUI
import BlocksModels

struct MoveToSearchView: View {    
    let onSelect: (BlockId) -> ()
    
    var body: some View {
        SearchView(title: "Move to") { data in
            onSelect(data.id)
        }
    }
}
