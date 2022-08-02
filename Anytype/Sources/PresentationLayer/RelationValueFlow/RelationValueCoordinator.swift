import Foundation
import BlocksModels
import UIKit
import AnytypeCore

final class RelationValueCoordinator: RelationValueCoordinatorProtocol,
                                      TextRelationActionButtonViewModelDelegate,
                                      RelationValueViewModelOutput {
    
    private weak var viewController: UIViewController?
    private let relationValueModuleAssembly: RelationValueModuleAssemblyProtocol
    private let urlOpener: URLOpenerProtocol
    private weak var output: RelationValueCoordinatorOutput?
    
    init(
        viewController: UIViewController?,
        relationValueModuleAssembly: RelationValueModuleAssemblyProtocol,
        urlOpener: URLOpenerProtocol
    ) {
        self.viewController = viewController
        self.relationValueModuleAssembly = relationValueModuleAssembly
        self.urlOpener = urlOpener
    }
    
    // MARK: - RelationValueCoordinatorProtocol
    
    func startFlow(
        objectId: BlockId,
        source: RelationSource,
        relation: Relation,
        output: RelationValueCoordinatorOutput
    ) {
        self.output = output
        
        guard relation.isEditable || (relation.hasDetails && FeatureFlags.relationDetails) else { return }
        
        if case .checkbox(let checkbox) = relation {
            let relationsService = RelationsService(objectId: objectId)
            relationsService.updateRelation(relationKey: checkbox.id, value: (!checkbox.value).protobufValue)
            return
        }
        
        guard let moduleViewController = relationValueModuleAssembly.make(
            objectId: objectId,
            source: source,
            relation: relation,
            delegate: self,
            output: self
        ) else { return }
        
        viewController?.topPresentedController.present(moduleViewController, animated: true, completion: nil)
    }
    
    // MARK: - TextRelationActionButtonViewModelDelegate
    
    func canOpenUrl(_ url: URL) -> Bool {
        urlOpener.canOpenUrl(url)
    }
    
    func openUrl(_ url: URL) {
        urlOpener.openUrl(url)
    }
    
    // MARK: - RelationValueViewModelOutput
    
    func onTapRelation(pageId: BlockId, viewType: EditorViewType) {
        output?.openObject(pageId: pageId, viewType: viewType)
    }
}
