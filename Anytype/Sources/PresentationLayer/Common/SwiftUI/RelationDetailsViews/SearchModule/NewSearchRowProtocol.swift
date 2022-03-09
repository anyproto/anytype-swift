import Foundation
import SwiftUI

protocol NewSearchRowProtocol: Identifiable, Hashable {
    
    var id: UUID { get }
    
    @ViewBuilder
    func view(onTap: @escaping () -> ()) -> AnyView
    
}
