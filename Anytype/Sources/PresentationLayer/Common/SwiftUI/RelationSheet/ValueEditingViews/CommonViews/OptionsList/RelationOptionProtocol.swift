import Foundation
import SwiftUI

protocol RelationOptionProtocol {
    
    var id: String { get }
    
    func makeView() -> AnyView
}
