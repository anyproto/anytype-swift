import SwiftUI
import AnytypeCore

struct DefaultTypePicker: View {
    @EnvironmentObject private var model: SettingsViewModel
    
    var body: some View {
        NewSearchModuleAssembly.changeObjectTypeSearchModule(
            title: "Choose default object type".localized,
            excludedObjectTypeId: nil
        ) { [weak model] id in
            UserDefaultsConfig.defaultObjectType = id
            model?.defaultType = false
            model?.personalization = false
        }
    }
}

struct DefaultTypePicker_Previews: PreviewProvider {
    static var previews: some View {
        DefaultTypePicker()
    }
}
