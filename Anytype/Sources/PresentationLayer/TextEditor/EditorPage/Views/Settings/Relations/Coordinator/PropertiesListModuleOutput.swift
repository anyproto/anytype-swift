import Foundation

@MainActor
protocol PropertiesListModuleOutput: AnyObject {
    func editRelationValueAction(document: some BaseDocumentProtocol, relationKey: String)
    func showTypeRelationsView(typeId: String)
}
