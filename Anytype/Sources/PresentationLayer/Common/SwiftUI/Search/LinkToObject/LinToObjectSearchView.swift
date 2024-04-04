import Foundation
import SwiftUI

struct LinToObjectSearchView: View {
    
    let data: LinkToObjectSearchModuleData
    let showEditorScreen: (_ data: EditorScreenData) -> Void
    
    var body: some View {
        // TODO: Refactoring module. Migrate from Search View
        SearchView(
            title: Loc.linkTo,
            viewModel: LinkToObjectSearchViewModel(data: data, showEditorScreen: showEditorScreen)
        )
    }
}
