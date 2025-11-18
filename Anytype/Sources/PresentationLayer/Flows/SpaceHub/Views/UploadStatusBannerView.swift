import SwiftUI
import DesignKit

struct UploadStatusBannerView: View {
    let count: Int

    var body: some View {
        HStack(spacing: 12) {
            CircleLoadingView(Color.Control.primary)
                .frame(width: 20, height: 20)

            Text(Loc.filesUploading(count))
                .font(AnytypeFontBuilder.font(anytypeFont: .uxCalloutMedium))
                .foregroundColor(Color.Text.primary)
                .contentTransition(.numericText())
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            Capsule()
                .fill(Color.Background.primary)
                .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 2)
        )
    }
}

#Preview {
    VStack(spacing: 20) {
        UploadStatusBannerView(count: 1)
        UploadStatusBannerView(count: 5)
        UploadStatusBannerView(count: 42)
    }
    .padding()
    .background(Color.Background.secondary)
}
