import SwiftUI

extension View {
    
    func messageLinkRemoveButton(onTapRemove: (() -> Void)?) -> some View {
        ifLet(onTapRemove) { view, onTapRemove in
            view.overlay(alignment: .topTrailing) {
                Button {
                    onTapRemove()
                } label: {
                    IconView(asset: .X18.clear)
                }
                .padding([.top, .trailing], -6)
            }
        }
    }
}
