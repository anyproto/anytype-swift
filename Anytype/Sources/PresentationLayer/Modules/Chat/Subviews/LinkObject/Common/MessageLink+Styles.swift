import SwiftUI

extension View {
    
    func messageLinkStyle() -> some View {
        cornerRadius(8, style: .continuous)
            .messageLinkShadow()
    }
    
    func messageLinkRemoveButton(onTapRemove: (() -> Void)?) -> some View {
        ifLet(onTapRemove) { view, onTapRemove in
            view.overlay(alignment: .topTrailing) {
                IconView(asset: .X18.clear)
                    .padding([.top, .trailing], -6)
                    .increaseTapGesture(EdgeInsets(side: 10)) {
                        onTapRemove()
                    }
            }
        }
    }
    
    func messageLinkShadow() -> some View {
        shadow(color: .Additional.messageInputShadow, radius: 4)
    }
    
    func messageLinkObjectStyle() -> some View {
        frame(width: 216, height: 72)
            .background(Color.Background.secondary)
            .cornerRadius(12, style: .continuous)
            .outerBorder(12, color: .Shape.tertiary, lineWidth: 1)
            .shadow(color: .Additional.messageInputShadow, radius: 4)
    }
}
