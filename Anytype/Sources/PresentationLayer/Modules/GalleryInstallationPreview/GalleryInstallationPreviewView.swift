import Foundation
import SwiftUI
import Services

struct GalleryInstallationPreviewView: View {
    
    @StateObject private var model: GalleryInstallationPreviewViewModel
    
    init(data: GalleryInstallationData, output: (any GalleryInstallationPreviewModuleOutput)?) {
        _model = StateObject(wrappedValue: GalleryInstallationPreviewViewModel(data: data, output: output))
    }
    
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
        .presentationCornerRadius(16)
    }
    
    private var errorState: some View {
        EmptyStateView(
            title: Loc.Error.Common.title,
            subtitle: Loc.Error.Common.message,
            style: .error,
            buttonData: EmptyStateView.ButtonData(
                title: Loc.tryAgain,
                action: { model.onTryAgainTap() }
            )
        )
    }
}
