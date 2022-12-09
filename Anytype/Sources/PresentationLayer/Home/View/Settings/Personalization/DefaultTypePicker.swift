import SwiftUI
import AnytypeCore
import BlocksModels

struct DefaultTypePicker: View {
    @EnvironmentObject private var model: SettingsViewModel
    
    private let newSearchModuleAssembly: NewSearchModuleAssemblyProtocol
    
    init(newSearchModuleAssembly: NewSearchModuleAssemblyProtocol) {
        self.newSearchModuleAssembly = newSearchModuleAssembly
    }
    
    var body: some View {
        newSearchModuleAssembly.objectTypeSearchModule(
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
        DefaultTypePicker(newSearchModuleAssembly: DI.makeForPreview().modulesDI.newSearch)
    }
}
