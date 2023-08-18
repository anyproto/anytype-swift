import Foundation

protocol RelationsListModuleOutput: AnyObject {
    func addNewRelationAction(document: BaseDocumentProtocol)
    func editRelationValueAction(document: BaseDocumentProtocol, relationKey: String)
}
