import Foundation
import BlocksModels
import Combine

protocol WidgetObjectListInternalViewModelProtocol: AnyObject {
    
    var title: String { get }
    var rowDetailsPublisher: AnyPublisher<[ObjectDetails], Never> { get }
    var editorViewType: EditorViewType { get }
    var showType: Bool { get }
    
    func onAppear()
    func onDisappear()
}

extension WidgetObjectListInternalViewModelProtocol {
    var showType: Bool { true }
}
