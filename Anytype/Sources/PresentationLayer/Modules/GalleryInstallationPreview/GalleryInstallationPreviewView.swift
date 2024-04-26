import Foundation
import SwiftUI
import Services

struct GalleryInstallationPreviewView: View {
    
    @StateObject var model: GalleryInstallationPreviewViewModel
    
    var body: some View {
        ZStack(alignment: .top) {
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
            DragIndicator()
        }
        .presentationCornerRadiusLegacy(16)
    }
    
    private var errorState: some View {
        EmptyStateView(
            title: Loc.Error.Common.title,
            subtitle: Loc.Error.Common.message,
            actionText: Loc.Error.Common.tryAgain,
            action: { model.onTryAgainTap() }
        )
    }
}
