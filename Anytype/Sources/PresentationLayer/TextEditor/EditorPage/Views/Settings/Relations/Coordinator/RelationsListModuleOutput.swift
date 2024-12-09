import Foundation

@MainActor
protocol RelationsListModuleOutput: AnyObject {
    func editRelationValueAction(document: some BaseDocumentProtocol, relationKey: String)
    func showTypeRelationsView(typeId: String)
}
