import Foundation
import SwiftUI
import AnytypeCore

struct CustomIconView: View {
    
    let icon: CustomIcon
    let color: Color
    
    var body: some View {
        Image(asset: icon.imageAsset)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .foregroundStyle(color)
    }
}

extension CustomIconView {
    init(icon: CustomIcon, iconColor: CustomIconColor) {
        self.icon = icon
        self.color = iconColor.color
    }
}
