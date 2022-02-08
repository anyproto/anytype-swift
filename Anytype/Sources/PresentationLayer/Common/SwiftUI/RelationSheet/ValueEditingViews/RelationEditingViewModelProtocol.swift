import Foundation
import SwiftUI

protocol RelationEditingViewModelProtocol: Dismissible {
    
    var onDismiss: () -> Void { get set }
        
    @ViewBuilder
    func makeView() -> AnyView
    
}
