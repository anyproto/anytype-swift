import Foundation
import Services

protocol RelationValueViewModelOutput: AnyObject {
    func onTapRelation(pageId: BlockId, viewType: EditorViewType)
}
