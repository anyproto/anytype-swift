import Foundation
import SwiftUI

protocol RelationEditingViewModelProtocol {
    
    var onDismiss: (() -> Void)? { get set }
    
    func saveValue()
    
    @ViewBuilder
    func makeView() -> AnyView
    func viewWillDisappear()
    
}


protocol RelationEditingViewModelProtocol2 {
    
    var onDismiss: (() -> Void)? { get set }
        
    @ViewBuilder
    func makeView() -> AnyView
    
}
