import SwiftUI

extension View {

    func messageLinkStyle() -> some View {
        clipShape(.rect(cornerRadius: 8, style: .continuous))
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
    
    func messageLinkObjectStyle() -> some View {
        frame(width: 216, height: 72)
            .background(Color.Background.secondary)
            .clipShape(.rect(cornerRadius: 12, style: .continuous))
    }
}
