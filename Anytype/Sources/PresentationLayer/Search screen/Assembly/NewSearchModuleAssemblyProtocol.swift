import Foundation
import Services
import SwiftUI

protocol NewSearchModuleAssemblyProtocol {
    
    func relationsSearchModule(
        document: BaseDocumentProtocol,
        excludedRelationsIds: [String],
        target: RelationsModuleTarget,
        output: RelationSearchModuleOutput
    ) -> NewSearchView
}
