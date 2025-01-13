import SwiftUI

@MainActor
protocol ObjectRelationListModuleOutput: AnyObject {
    func onClose()
    func onObjectOpen(screenData: ScreenData?)
    func onDeleteTap(completion: @escaping (_ isSuccess: Bool) -> Void)
}
