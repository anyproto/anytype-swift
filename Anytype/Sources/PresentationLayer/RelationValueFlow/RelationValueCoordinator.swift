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
        relationValue: RelationValue,
        output: RelationValueCoordinatorOutput
    ) {
        self.output = output
        
        guard relationValue.isEditable || (relationValue.hasDetails && FeatureFlags.relationDetails) else { return }
        
        if case .checkbox(let checkbox) = relationValue {
            let relationsService = RelationsService(objectId: objectId)
            relationsService.updateRelation(relationKey: checkbox.key, value: (!checkbox.value).protobufValue)
            return
        }
        
        guard let moduleViewController = relationValueModuleAssembly.make(
            objectId: objectId,
            source: source,
            relationValue: relationValue,
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
