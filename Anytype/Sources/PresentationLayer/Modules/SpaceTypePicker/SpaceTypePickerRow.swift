import SwiftUI

struct SpaceTypePickerRow: View {
    
    let icon: ImageAsset
    let title: String
    let subtitle: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(asset: icon)
            VStack(spacing: 0) {
                Text(title)
                    .anytypeStyle(.uxTitle1Semibold)
                    .foregroundStyle(Color.Text.primary)
                Text(subtitle)
                    .anytypeStyle(.uxTitle1Semibold)
                    .foregroundStyle(Color.Control.transparentActive)
            }
        }
    }
}
