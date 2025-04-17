import SwiftUI
import Services
import AnytypeCore


@MainActor
final class ObjectTypeInfoViewModel: ObservableObject {
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
    
    private let completion: (_ info: ObjectTypeInfo) -> ()
    
    init(info: ObjectTypeInfo, completion: @escaping (_ info: ObjectTypeInfo) -> ()) {
        self.name = info.singularName
        self.pluralName = info.pluralName
        self.icon = info.icon
        self.color = info.color
    
        self.completion = completion
    }
    
    func onNameChange(old: String, new: String) {
        if pluralName.isEmpty || pluralName == old {
            pluralName = new
        }
    }
    
    func onSaveTap() {
        dismiss?()
        completion(ObjectTypeInfo(singularName: name, pluralName: pluralName, icon: icon, color: color))
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
