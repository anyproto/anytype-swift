import Foundation
import BlocksModels
import Combine

protocol MarkupViewModelAdapterProtocol: AnyObject {
    var selectedMarkupsPublisher: AnyPublisher<[MarkupType: AttributeState], Never> { get }
    var selectedHorizontalAlignmentPublisher: AnyPublisher<[LayoutAlignment: AttributeState], Never> { get }
    
    func onMarkupAction(_ action: MarkupViewModelAction)
}
