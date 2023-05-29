import Foundation
import BlocksModels

protocol RelationValueViewModelOutput: AnyObject {
    func onTapRelation(pageId: BlockId, viewType: EditorViewType)
}
