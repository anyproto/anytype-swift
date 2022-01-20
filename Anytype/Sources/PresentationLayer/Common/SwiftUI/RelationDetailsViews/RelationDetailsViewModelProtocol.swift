import Foundation
import SwiftUI

protocol RelationDetailsViewModelProtocol {
    
    var onViewHeightUpdate: ((CGFloat) -> Void)? { get set }
        
    @ViewBuilder func makeView() -> AnyView
    
}
