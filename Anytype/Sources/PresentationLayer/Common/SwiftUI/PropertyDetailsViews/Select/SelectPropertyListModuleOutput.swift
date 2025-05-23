import SwiftUI

@MainActor
protocol SelectPropertyListModuleOutput: AnyObject {
    func onClose()
    func onCreateTap(text: String?, color: Color?, completion: @escaping (_ option: SelectPropertyOption) -> Void)
    func onEditTap(option: SelectPropertyOption, completion: @escaping (_ option: SelectPropertyOption) -> Void)
    func onDeleteTap(completion: @escaping (_ isSuccess: Bool) -> Void)
}
