import Foundation
import SwiftUI

protocol RelationDetailsViewModelProtocol {
    
    var heightPublisher: Published<CGFloat>.Publisher { get }
        
    @ViewBuilder func makeView() -> AnyView
    
}
