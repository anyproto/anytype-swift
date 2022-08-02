import UIKit

protocol TextRelationDetailsViewModelProtocol {
    var value: String { get }
    var title: String { get }
    var isEditable: Bool { get }
    var type: TextRelationDetailsViewType { get }
    var actionButtonViewModel: TextRelationActionButtonViewModel? { get }
    
    func updatePopupLayout(_ layoutGuide: UILayoutGuide)
    func updateValue(_ text: String)
}
