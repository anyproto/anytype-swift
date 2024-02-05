import Foundation
import SwiftUI
import Services

struct GalleryInstallationPreviewView: View {
    
    @StateObject var model: GalleryInstallationPreviewViewModel
    
    var body: some View {
        Group {
            switch model.state {
            case .data(let manifest):
                GalleryInstallationPreviewManifestView(manifest: manifest, onTapInstall: { model.onTapInstall() })
            case .loading(let manifest):
                GalleryInstallationPreviewManifestView(manifest: manifest, onTapInstall: { })
                    .redacted(reason: .placeholder)
                    .allowsHitTesting(false)
            case .error:
                errorState
            }
        }
        .presentationCornerRadiusLegacy(16)
    }
    
    private var errorState: some View {
        VStack(spacing: 0) {
            Spacer()
            ButtomAlertHeaderImageView(icon: .BottomAlert.error, style: .red)
            Spacer.fixedHeight(12)
            AnytypeText(Loc.unknownError, style: .uxCalloutMedium, color: .Text.primary)
            Spacer()
        }
    }
}
