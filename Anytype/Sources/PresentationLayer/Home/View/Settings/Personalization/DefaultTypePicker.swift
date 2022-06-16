import SwiftUI
import AnytypeCore
import BlocksModels

struct DefaultTypePicker: View {
    @EnvironmentObject private var model: SettingsViewModel
    
    var body: some View {
        NewSearchModuleAssembly.objectTypeSearchModule(
            title: "Choose default object type".localized,
            excludedObjectTypeId: ObjectTypeUrl.bundled(.bookmark).rawValue
        ) { [weak model] id in
            ObjectTypeProvider.shared.objectType(url: id).flatMap {
                UserDefaultsConfig.defaultObjectType = $0
            }
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
