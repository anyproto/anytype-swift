import Foundation
import SwiftUI

protocol RelationValueEditingViewProtocol: View {
    
    var title: String { get }
    
    func saveValue()
    
}
