import Foundation

@MainActor
protocol RelationsListModuleOutput: AnyObject {
    func addNewRelationAction(document: some BaseDocumentProtocol)
    func editRelationValueAction(document: some BaseDocumentProtocol, relationKey: String)
}
