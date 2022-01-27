import Foundation
import SwiftUI

protocol RelationEditingViewModelProtocol: Dismissible {
    
    var onDismiss: () -> Void { get set }
        
    func makeView() -> AnyView
    
}
