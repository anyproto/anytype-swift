import SwiftUI

@MainActor
protocol SelectRelationListModuleOutput: AnyObject {
    func onClose()
    func onCreateTap(text: String?, color: Color?, completion: @escaping (_ optionId: String) -> Void)
    func onEditTap(option: SelectRelationOption, completion: @escaping () -> Void)
}
