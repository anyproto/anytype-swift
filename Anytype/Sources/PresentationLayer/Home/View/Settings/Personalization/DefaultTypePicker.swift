import SwiftUI
import AnytypeCore

struct DefaultTypePicker: View {
    @EnvironmentObject private var model: SettingsViewModel
    
    var body: some View {
        let searchViewModel = ObjectSearchViewModel(searchKind: .objectTypes(currentObjectTypeUrl: "")) { [weak model] data in
            UserDefaultsConfig.defaultObjectType = data.blockId
            model?.defaultType = false
            model?.personalization = false
        }
        return SearchView(title: "Choose default object type".localized, context: .menuSearch, viewModel: searchViewModel)
    }
}

struct DefaultTypePicker_Previews: PreviewProvider {
    static var previews: some View {
        DefaultTypePicker()
    }
}
