import Foundation
import SwiftUI

protocol RelationValueEditingViewModelProtocol {
        
    func saveValue()
    
    @ViewBuilder
    func makeView() -> AnyView
    
}
