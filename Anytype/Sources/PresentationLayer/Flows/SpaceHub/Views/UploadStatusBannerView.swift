import SwiftUI
import DesignKit

struct UploadStatusBannerView: View {
    let text: String

    var body: some View {
        HStack(spacing: 6) {
            CircleLoadingView(Color.Control.primary)
                .frame(width: 18, height: 18)

            Text(text)
                .font(AnytypeFontBuilder.font(anytypeFont: .caption1Medium))
                .foregroundColor(Color.Text.secondary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(
            Capsule()
                .fill(Color.Background.secondary)
                .shadow(color: Color.black.opacity(0.15), radius: 40, x: 0, y: 8)
        )
    }
}

#Preview {
    VStack(spacing: 20) {
        UploadStatusBannerView(text: "1 file uploading")
        UploadStatusBannerView(text: "5 files uploading")
        UploadStatusBannerView(text: "Syncing...")
    }
    .padding()
    .background(Color.Background.secondary)
}
