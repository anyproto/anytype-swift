import Foundation
import Services

protocol RelationValueCoordinatorOutput: AnyObject {
    func openObject(pageId: BlockId, viewType: EditorViewType)
}
