import Foundation
import SwiftUI

struct HomeBottomPanelView: View {
    
    @StateObject var model: HomeBottomPanelViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            if model.homeState.isEditWidgets {
                editButtons
            }
        }
        .animation(.default, value: model.homeState)
    }
    
    private var editButtons: some View {
        HStack(alignment: .center, spacing: 10) {
            makeButton(action: { model.onTapAdd() }, text: Loc.add)
            makeButton(action: { model.onTapDone() }, text: Loc.done)
        }
        .padding(.horizontal, 26)
        .padding(.vertical, 10)
        .transition(.scale(scale: 0.8).combined(with: .opacity))
    }
    
    private func makeButton(action: @escaping () -> Void, text: String) -> some View {
        Button(action: action, label: {
            AnytypeText(text, style: .uxBodyRegular, color: .Text.white)
                .frame(maxWidth: .infinity)
        })
        .frame(height: 52)
        .background(Color.Widget.bottomPanel)
        .background(.ultraThinMaterial)
        .cornerRadius(14, style: .continuous)
    }
}
