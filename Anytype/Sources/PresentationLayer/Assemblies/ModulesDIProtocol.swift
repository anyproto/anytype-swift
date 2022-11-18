import Foundation

protocol ModulesDIProtocol: AnyObject {
    var relationValue: RelationValueModuleAssemblyProtocol { get }
    var undoRedo: UndoRedoModuleAssemblyProtocol { get }
    var objectLayoutPicker: ObjectLayoutPickerModuleAssemblyProtocol { get }
    var objectCoverPicker: ObjectCoverPickerModuleAssemblyProtocol { get }
    var objectIconPicker: ObjectIconPickerModuleAssemblyProtocol { get }
}
