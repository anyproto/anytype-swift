import Foundation

protocol ModulesDIProtocol: AnyObject {
    var relationValue: RelationValueModuleAssemblyProtocol { get }
    var relationsList: RelationsListModuleAssemblyProtocol { get }
    var undoRedo: UndoRedoModuleAssemblyProtocol { get }
    var objectLayoutPicker: ObjectLayoutPickerModuleAssemblyProtocol { get }
    var objectCoverPicker: ObjectCoverPickerModuleAssemblyProtocol { get }
    var objectIconPicker: ObjectIconPickerModuleAssemblyProtocol { get }
    var objectSetting: ObjectSettingModuleAssemblyProtocol { get }
    var search: SearchModuleAssemblyProtocol { get }
    var createObject: CreateObjectModuleAssemblyProtocol { get }
    var codeLanguageList: CodeLanguageListModuleAssemblyProtocol { get }
    var newSearch: NewSearchModuleAssemblyProtocol { get }
}
