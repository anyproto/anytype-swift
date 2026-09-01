import Foundation
import SwiftUI

// Floating banner on the vault screen after a quick capture is published,
// tapping it jumps into the created object
struct QuickCaptureCreatedBannerView: View {

    let banner: QuickCaptureCreatedBanner
    let onTap: () -> Void

    var body: some View {
        Button {
            onTap()
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 22))
                    .foregroundStyle(Color.Pure.green)
                AnytypeText(Loc.QuickCapture.typeCreatedIn(banner.typeName, banner.spaceName), style: .uxCalloutRegular)
                    .foregroundStyle(Color.Text.primary)
                    .lineLimit(1)
                Spacer(minLength: 12)
                AnytypeText(Loc.QuickCapture.openObject, style: .uxCalloutMedium)
                    .foregroundStyle(Color.Text.secondary)
                    .lineLimit(1)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .frame(maxWidth: .infinity)
            .background(Color.Background.secondary)
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.25), radius: 10, y: 4)
        }
        .padding(.horizontal, 16)
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }
}
