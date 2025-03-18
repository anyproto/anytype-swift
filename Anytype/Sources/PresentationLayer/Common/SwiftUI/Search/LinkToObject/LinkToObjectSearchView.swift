import Foundation
import SwiftUI

struct LinkToObjectSearchView: View {
    
    @StateObject private var model: LinkToObjectSearchViewModel
    @Environment(\.openURL) private var openURL
    
    init(data: LinkToObjectSearchModuleData, showEditorScreen: @escaping (_ data: ScreenData) -> Void) {
        self._model = StateObject(wrappedValue: LinkToObjectSearchViewModel(data: data, showEditorScreen: showEditorScreen))
    }
    
    var body: some View {
        SearchView(
            title: Loc.linkTo,
            placeholder: Loc.Editor.LinkToObject.searchPlaceholder,
            searchData: model.searchData,
            emptyViewMode: .object,
            search:  { text in
                await model.search(text: text)
            },
            onSelect: { data in
                model.onSelect(searchData: data)
            }
        )
        .onChange(of: model.openUrl) { url in
            guard let url else { return }
            openURL(url)
        }
    }
}
