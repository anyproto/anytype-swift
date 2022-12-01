import SwiftUI
import AnytypeCore
import BlocksModels

struct DefaultTypePicker: View {
    @EnvironmentObject private var model: SettingsViewModel
    
    var body: some View {
        NewSearchModuleAssembly.objectTypeSearchModule(
            title: Loc.chooseDefaultObjectType,
            showBookmark: false
        ) { [weak model] id in
            ObjectTypeProvider.shared.setDefaulObjectType(id: id)
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
