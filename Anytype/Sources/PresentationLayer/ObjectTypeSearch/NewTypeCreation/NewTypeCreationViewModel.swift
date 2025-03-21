import SwiftUI
import Services
import AnytypeCore


@MainActor
final class NewTypeCreationViewModel: ObservableObject {
    @Published var showIconPicker = false
    
    @Published var name = ""
    @Published var pluralName = ""
    var objectIcon: ObjectIcon {
        guard let icon else { return ObjectIcon.emptyTypeIcon }
        
        return ObjectIcon.customIcon(CustomIconData(icon: icon, customColor: color ?? .default))
    }
    var isRemoveIconButtonAvailable: Bool { icon.isNotNil }
    
    var dismiss: DismissAction?
    
    @Published private var icon: CustomIcon?
    @Published private var color: CustomIconColor?
    
    @Injected(\.typesService)
    private var typesService: any TypesServiceProtocol
    
    private let completion: (_ name: String, _ pluralName: String, _ icon: CustomIcon?, _ color: CustomIconColor?) -> ()
    
    init(name: String, pluralName: String, completion: @escaping (_ name: String, _ pluralName: String, _ icon: CustomIcon?, _ color: CustomIconColor?) -> ()) {
        self.name = name
        self.pluralName = pluralName
        self.completion = completion
    }
    
    func onNameChange(old: String, new: String) {
        if pluralName.isEmpty || pluralName == old {
            pluralName = new
        }
    }
    
    func onSaveTap() {
        dismiss?()
        completion(name, pluralName, icon, color)
    }
    
    func onIconTap() {
        showIconPicker.toggle()
    }
    
    func onIconSelect(icon: CustomIcon, color: CustomIconColor) {
        self.icon = icon
        self.color = color
    }
    
    func onIconDelete() {
        self.icon = nil
        self.color = nil
    }
}
