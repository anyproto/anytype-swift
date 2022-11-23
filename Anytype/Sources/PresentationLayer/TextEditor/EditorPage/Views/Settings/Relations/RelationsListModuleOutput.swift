import Foundation

protocol RelationsListModuleOutput: AnyObject {
    func addNewRelationAction()
    func editRelationValueAction(relationKey: String)
}
