import SwiftUI
import AnytypeCore

struct DefaultTypePicker: View {
    @EnvironmentObject private var model: SettingsViewModel
    
    var body: some View {
        let searchViewModel = ObjectSearchViewModel(searchKind: .objectTypes(currentObjectTypeUrl: "")) { [weak model] blockId in
            UserDefaultsConfig.defaultObjectType = blockId
            model?.defaultType = false
        }
        return SearchView(title: "Choose default object type".localized, viewModel: searchViewModel)
    }
}

struct DefaultTypePicker_Previews: PreviewProvider {
    static var previews: some View {
        DefaultTypePicker()
    }
}
