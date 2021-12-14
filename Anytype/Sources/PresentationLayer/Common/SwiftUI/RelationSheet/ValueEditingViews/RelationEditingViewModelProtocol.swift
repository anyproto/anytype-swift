import Foundation
import SwiftUI

protocol RelationEditingViewModelProtocol {
    
    func saveValue()
    
    @ViewBuilder
    func makeView() -> AnyView
    func viewWillDisappear()
    
}
