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
}
