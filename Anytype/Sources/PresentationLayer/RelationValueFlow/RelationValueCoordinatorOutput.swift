import Foundation
import BlocksModels

protocol RelationValueCoordinatorOutput: AnyObject {
    func openObject(pageId: BlockId, viewType: EditorViewType)
}
