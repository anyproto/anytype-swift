import SwiftUI

public extension View {
    
    func eraseToAnyView() -> AnyView {
        .init(self)
    }
}
