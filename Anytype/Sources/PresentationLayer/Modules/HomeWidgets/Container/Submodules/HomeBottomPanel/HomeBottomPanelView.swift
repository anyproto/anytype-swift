import Foundation
import SwiftUI

struct HomeBottomPanelView: View {
    
    @ObservedObject var model: HomeBottomPanelViewModel
    
    var body: some View {
        HStack(alignment: .center, spacing: 40) {
            ForEach(model.buttons, id:\.self) { button in
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
}
