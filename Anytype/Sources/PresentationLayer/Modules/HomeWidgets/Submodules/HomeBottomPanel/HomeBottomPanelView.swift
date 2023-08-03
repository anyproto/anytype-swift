import Foundation
import SwiftUI

struct HomeBottomPanelView: View {
    
    @ObservedObject var model: HomeBottomPanelViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            switch model.buttonState {
            case let .normal(buttons):
                normalButtons(buttons)
            case let .edit(buttons):
                editButtons(buttons)
            }
            Spacer.fixedHeight(32)
        }
        .animation(.default, value: model.isEditState)
    }

    @ViewBuilder
    func normalButtons(_ buttons: [HomeBottomPanelViewModel.ImageButton]) -> some View {
        HStack(alignment: .center, spacing: 40) {
            ForEach(buttons, id:\.self) { button in
                Button(action: button.onTap, label: {
                    VStack {
                        if let image = button.image {
                            SwiftUIObjectIconImageView(iconImage: image, usecase: .homeBottomPanel)
                        }
                    }
                    .fixTappableArea()
                    .frame(width: 32, height: 32)
                })
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
        .background(Color.Background.material)
        .background(.ultraThinMaterial)
        .cornerRadius(16, style: .continuous)
        .transition(.scale(scale: 0.8).combined(with: .opacity))
    }
    
    @ViewBuilder
    func editButtons(_ buttons: [HomeBottomPanelViewModel.TexButton]) -> some View {
        HStack(alignment: .center, spacing: 10) {
            ForEach(buttons, id:\.self) { button in
                Button(action: button.onTap, label: {
                    AnytypeText(button.text, style: .uxBodyRegular, color: .Text.white)
                        .frame(maxWidth: .infinity)
                })
                .frame(height: 52)
                .background(Color.Background.material)
                .background(.ultraThinMaterial)
                .cornerRadius(14, style: .continuous)
            }
        }
        .padding(.horizontal, 26)
        .transition(.scale(scale: 0.8).combined(with: .opacity))
    }
}
