import Foundation
import Services

@MainActor
protocol RelationValueViewModelOutput: AnyObject {
    func onTapRelation(screenData: EditorScreenData)
}
