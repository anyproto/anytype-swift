import UIKit

@MainActor
protocol TextRelationDetailsViewModelProtocol {
    var value: String { get }
    var title: String { get }
    var isEditable: Bool { get }
    var type: TextRelationViewType { get }
    var actionsViewModel: [TextRelationActionViewModelProtocol] { get }
    
    func updatePopupLayout(_ layoutGuide: UILayoutGuide)
    func updateValue(_ text: String)
    func onWillDisappear()
}
