import SwiftUI

@MainActor
protocol SelectRelationListModuleOutput: AnyObject {
    func onClose()
    func onCreateTap(text: String?, color: Color?, completion: @escaping (_ option: SelectRelationOption) -> Void)
    func onEditTap(option: SelectRelationOption, completion: @escaping (_ option: SelectRelationOption) -> Void)
    func onDeleteTap(completion: @escaping (_ isSuccess: Bool) -> Void)
}
