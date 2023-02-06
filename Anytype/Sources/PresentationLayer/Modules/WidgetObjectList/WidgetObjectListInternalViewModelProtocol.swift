import Foundation
import BlocksModels
import Combine

protocol WidgetObjectListInternalViewModelProtocol: AnyObject {
    
    var title: String { get }
    var rowDetailsPublisher: AnyPublisher<[ObjectDetails], Never> { get }
    var editorViewType: EditorViewType { get }
    
    func onAppear()
    func onDisappear()
}
