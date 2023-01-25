import Foundation
import SwiftUI

struct HomeBottomPanelView: View {
    
    @ObservedObject var model: HomeBottomPanelViewModel
    
    var body: some View {
        switch model.buttonState {
        case let .normal(buttons):
            normalButtons(buttons)
        case let .edit(buttons):
            editButtons(buttons)
        }
    }

    @ViewBuilder
    func normalButtons(_ buttons: [HomeBottomPanelViewModel.ImageButton]) -> some View {
        HStack(alignment: .center, spacing: 40) {
            ForEach(buttons, id:\.self) { button in
                Button(action: button.onTap, label: {
                    SwiftUIObjectIconImageView(iconImage: button.image, usecase: .homeBottomPanel)
                })
                .frame(width: 32, height: 32)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
        .background(Color.Background.material)
        .backgroundMaterial(.thinMaterial)
        .cornerRadius(16, style: .continuous)
    }
    
    @ViewBuilder
    func editButtons(_ buttons: [HomeBottomPanelViewModel.TexButton]) -> some View {
        HStack(alignment: .center, spacing: 10) {
            ForEach(buttons, id:\.self) { button in
                Button(action: button.onTap, label: {
                    AnytypeText(button.text, style: .uxBodyRegular, color: .Text.white)
                        .frame(maxWidth: .infinity)
                })
                .frame(height: 48)
                .background(Color.Background.material)
                .backgroundMaterial(.thinMaterial)
                .cornerRadius(14, style: .continuous)
            }
        }
        .padding(.horizontal, 26)
//        .frame(minWidth: 0, maxWidth: .infinity)
//        .fixedSize(horizontal: true, vertical: true)
//        .frame(width: .greatestFiniteMagnitude)
//        .padding(.horizontal, 25)
    }
}
