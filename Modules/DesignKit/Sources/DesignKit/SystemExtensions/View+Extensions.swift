import SwiftUI

public extension View {
    
    func eraseToAnyView() -> AnyView {
        .init(self)
    }
    
    func setZeroOpacity(_ shouldHide: Bool) -> some View {
        opacity(shouldHide ? 0 : 1)
    }
    
    func showGraph() -> some View {
        print(Mirror(reflecting: self))
        return self
    }
}
