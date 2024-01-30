import SwiftUI

@MainActor
protocol MultiSelectRelationListModuleOutput: AnyObject {
    func onCreateTap(text: String?, color: Color?, completion: @escaping (_ option: MultiSelectRelationOption) -> Void)
    func onEditTap(option: MultiSelectRelationOption, completion: @escaping (_ option: MultiSelectRelationOption) -> Void)
    func onDeleteTap(completion: @escaping (_ isSuccess: Bool) -> Void)
}
