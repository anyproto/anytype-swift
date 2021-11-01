import SwiftUI
import AnytypeCore

struct DefaultTypePicker: View {
    @EnvironmentObject private var model: SettingsViewModel
    
    var body: some View {
        SearchView(
            kind: .objectTypes(currentObjectTypeUrl: ""),
            title: "Choose default object type".localized) { blockId in
                UserDefaultsConfig.defaultObjectType = blockId
                model.defaultType = false
                model.other = false
            }
    }
}

struct DefaultTypePicker_Previews: PreviewProvider {
    static var previews: some View {
        DefaultTypePicker()
    }
}
