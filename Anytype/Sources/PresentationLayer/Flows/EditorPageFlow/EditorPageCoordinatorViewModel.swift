import Foundation
import SwiftUI
import AnytypeCore
import Services

@MainActor
final class EditorPageCoordinatorViewModel: ObservableObject, EditorPageModuleOutput, RelationValueCoordinatorOutput {
    
    private let data: EditorPageObject
    private let showHeader: Bool
    private let setupEditorInput: (EditorPageModuleInput, String) -> Void
    private let editorPageAssembly: EditorPageModuleAssemblyProtocol
    private let legacyRelationValueCoordinator: LegacyRelationValueCoordinatorProtocol
    private let relationValueCoordinatorAssembly: RelationValueCoordinatorAssemblyProtocol
    
    var pageNavigation: PageNavigation?
    @Published var dismiss = false
    @Published var relationValueData: RelationValueData?
    
    init(
        data: EditorPageObject,
        showHeader: Bool,
        setupEditorInput: @escaping (EditorPageModuleInput, String) -> Void,
        editorPageAssembly: EditorPageModuleAssemblyProtocol,
        legacyRelationValueCoordinator: LegacyRelationValueCoordinatorProtocol,
        relationValueCoordinatorAssembly: RelationValueCoordinatorAssemblyProtocol
    ) {
        self.data = data
        self.showHeader = showHeader
        self.setupEditorInput = setupEditorInput
        self.editorPageAssembly = editorPageAssembly
        self.legacyRelationValueCoordinator = legacyRelationValueCoordinator
        self.relationValueCoordinatorAssembly = relationValueCoordinatorAssembly
    }
    
    func pageModule() -> AnyView {
        return editorPageAssembly.make(data: data, output: self, showHeader: showHeader)
    }
    
    // MARK: - EditorPageModuleOutput
    
    func showEditorScreen(data: EditorScreenData) {
        pageNavigation?.push(data)
    }
    
    func replaceEditorScreen(data: EditorScreenData) {
        pageNavigation?.replace(data)
    }
    
    func closeEditor() {
        dismiss.toggle()
    }
    
    func setModuleInput(input: EditorPageModuleInput, objectId: String) {
        setupEditorInput(input, objectId)
    }
    
    func showRelationValueEditingView(document: BaseDocumentProtocol, relation: Relation) {
        guard let objectDetails = document.details else {
            anytypeAssertionFailure("Details not found")
            return
        }
        handleRelationValue(relation: relation, objectDetails: objectDetails)
    }
    
    func relationValueCoordinator(data: RelationValueData) -> AnyView {
        relationValueCoordinatorAssembly.make(
            relation: data.relation,
            objectDetails: data.objectDetails,
            analyticsType: .dataview, 
            output: self
        )
    }
    
    private func handleRelationValue(relation: Relation, objectDetails: ObjectDetails) {
        if RelationValueInteractor.canHandleRelation(relation) {
            relationValueData = RelationValueData(
                relation: relation,
                objectDetails: objectDetails
            )
        } else {
            legacyRelationValueCoordinator.startFlow(
                objectDetails: objectDetails,
                relation: relation,
                analyticsType: .block,
                output: self
            )
        }
    }
}

extension EditorPageCoordinatorViewModel {
    struct RelationValueData: Identifiable {
        let id = UUID()
        let relation: Relation
        let objectDetails: ObjectDetails
    }
}
