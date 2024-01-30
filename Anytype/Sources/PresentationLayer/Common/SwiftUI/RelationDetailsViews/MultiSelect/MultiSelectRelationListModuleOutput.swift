import SwiftUI

@MainActor
protocol MultiSelectRelationListModuleOutput: AnyObject {
    func onCreateTap(text: String?, color: Color?, completion: @escaping (_ optionId: String) -> Void)
    func onEditTap(option: MultiSelectRelationOption, completion: @escaping () -> Void)
    func onDeleteTap(completion: @escaping (_ isSuccess: Bool) -> Void)
}
