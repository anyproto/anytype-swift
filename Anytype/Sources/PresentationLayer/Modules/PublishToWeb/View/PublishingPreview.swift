import SwiftUI
import Services
import AnytypeCore

// TBD;
struct PublishingPreview: View {
    let data: PublishingPreviewData
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.orange)
                .frame(height: 200)
                .overlay(
                    VStack(spacing: 8) {
                        AnytypeText("Preview Placeholder", style: .uxTitle2Medium)
                            .foregroundColor(.white)
                        AnytypeText("Your published page will appear here", style: .uxCalloutRegular)
                            .foregroundColor(.white.opacity(0.8))
                    }
                )
        }
    }
}
