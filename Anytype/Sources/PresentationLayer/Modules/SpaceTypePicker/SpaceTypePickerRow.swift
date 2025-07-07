import SwiftUI

struct SpaceTypePickerRow: View {
    
    let icon: ImageAsset
    let title: String
    let subtitle: String
    let onTap: () -> Void
    
    var body: some View {
        Button {
            onTap()
        } label: {
            HStack(spacing: 12) {
                Image(asset: icon)
                VStack(alignment: .leading, spacing: 0) {
                    Text(title)
                        .anytypeStyle(.uxTitle1Semibold)
                        .foregroundStyle(Color.Text.primary)
                    if subtitle.isNotEmpty {
                        Text(subtitle)
                            .anytypeStyle(.caption1Regular)
                            .foregroundStyle(Color.Text.secondary)
                    }
                }
                .padding(.bottom, 2)
                Spacer()
            }
            .lineLimit(1)
            .padding(.vertical, 8)
            .padding(.horizontal, 16)
            .fixTappableArea()
        }
    }
}
