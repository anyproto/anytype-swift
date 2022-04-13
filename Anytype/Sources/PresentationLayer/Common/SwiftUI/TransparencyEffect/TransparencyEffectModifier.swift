import SwiftUI

struct TransparencyEffectModifier: ViewModifier {
   
    let edge: TransparencyEffect.Edge
    let length: CGFloat
    
    func body(content: Content) -> some View {
        content.overlay(TransparencyEffect(edge: edge, length: length))
    }
    
}
