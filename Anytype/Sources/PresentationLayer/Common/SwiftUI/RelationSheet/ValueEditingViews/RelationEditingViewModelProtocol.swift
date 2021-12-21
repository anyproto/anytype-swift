import Foundation
import SwiftUI

protocol RelationEditingViewModelProtocol {
    
    var dismissHandler: (() -> Void)? { get set }
        
    @ViewBuilder
    func makeView() -> AnyView
    
}
