import Foundation

protocol ModulesDIProtocol: AnyObject {
    var relationValue: RelationValueModuleAssemblyProtocol { get }
    var undoRedo: UndoRedoModuleAssemblyProtocol { get }
}
