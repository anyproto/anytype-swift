import Foundation
import SwiftUI

struct ProfileQRCodeView: View {

    let anyName: String = "vova.any"

    var body: some View {
        VStack(spacing: 0) {
            DragIndicator()
            Spacer.fixedHeight(12)

            HStack {
                Spacer()
                HStack(spacing: 4) {
                    AnytypeText(anyName, style: .uxBodyRegular)
                        .foregroundColor(.Text.primary)
                }
                Spacer()
            }

            Spacer.fixedHeight(24)

            RoundedRectangle(cornerRadius: 16)
                .fill(Color.Shape.tertiary)
                .frame(width: 200, height: 200)
                .overlay {
                    AnytypeText("QR Code", style: .bodyRegular)
                        .foregroundColor(.Text.secondary)
                }

            Spacer.fixedHeight(32)

            StandardButton(Loc.share, style: .primaryLarge) {
                // Stub action
            }

            Spacer.fixedHeight(12)

            StandardButton(Loc.download, style: .secondaryLarge) {
                // Stub action
            }

            Spacer.fixedHeight(16)
        }
        .padding(.horizontal, 20)
        .background(Color.Background.primary)
    }
}

#Preview {
    ProfileQRCodeView(anyName: "barulenkov.any")
}
