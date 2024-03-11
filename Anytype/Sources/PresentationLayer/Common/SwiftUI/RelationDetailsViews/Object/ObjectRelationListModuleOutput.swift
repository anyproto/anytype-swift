import SwiftUI

@MainActor
protocol ObjectRelationListModuleOutput: AnyObject {
    func onClose()
    func onObjectOpen(screenData: EditorScreenData?)
    func onDeleteTap(completion: @escaping (_ isSuccess: Bool) -> Void)
}
