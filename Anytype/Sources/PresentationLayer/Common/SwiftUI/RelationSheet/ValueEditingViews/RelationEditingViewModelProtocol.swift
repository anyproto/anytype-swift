import Foundation
import SwiftUI

protocol RelationEditingViewModelProtocol {
    
    var onDismiss: (() -> Void)? { get set }
        
    @ViewBuilder
    func makeView() -> AnyView
    
}
