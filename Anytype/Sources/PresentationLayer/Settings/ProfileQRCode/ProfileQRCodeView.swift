import SwiftUI
import QRCode
import Assets
import Services
import AnytypeCore

struct ProfileQRCodeView: View {

    @StateObject private var model = ProfileQRCodeViewModel()
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        content
            .sheet(item: $model.sharedUrl) { url in
                ActivityView(activityItems: [url.value])
            }
            .qrCodeScanner(shouldScan: $model.shouldScanQrCode)
            .snackbar(toastBarData: $model.toastBarData)
            .onAppear {
                model.onAppear()
            }
    }

    @ViewBuilder
    private var content: some View {
        VStack(spacing: 0) {
            DragIndicator()
            
            switch model.state {
            case .loading:
                EmptyView()
            case .error:
                EmptyStateView(title: Loc.error, style: .error)
            case .loaded(let lightDocument, let darkDocument, _):
                let document = colorScheme == .dark ? darkDocument : lightDocument
                loadedContent(document: document)
            }
        }
        .background(
            DashboardWallpaper(wallpaper: .blurredIcon, spaceIcon: model.profileIcon)
                .ignoresSafeArea()
        )
    }

    private func loadedContent(document: QRCode.Document) -> some View {
        VStack(spacing: 0) {
            Spacer.fixedHeight(12)
            headerRow
            Spacer(minLength: 24)
            
            qrCodeWithCircularText(document: document)
            
            Spacer(minLength: 32)
            StandardButton(Loc.copyLink, style: .primaryLarge) {
                model.onCopyLink()
            }
            Spacer.fixedHeight(12)
            StandardButton(Loc.share, style: .secondaryLarge) {
                model.onShare()
            }
            Spacer.fixedHeight(16)
        }
        .padding(.horizontal, 20)
    }

    private var headerRow: some View {
        HStack {
            Spacer()
            AnytypeText(model.anyName.isEmpty ? Loc.qrCode : model.anyName, style: .uxTitle1Semibold)
                .foregroundColor(.Text.primary)
            Spacer()
        }
        .overlay(alignment: .trailing) {
            Button { model.onScanTap() } label: {
                Image(asset: .X32.scanCode)
                    .frame(width: 32, height: 32)
                    .foregroundColor(.Text.primary)
            }
        }
    }

    private func qrCodeWithCircularText(document: QRCode.Document) -> some View {
        GeometryReader { geometry in
            let containerSize = min(geometry.size.width, geometry.size.height)
            let circularTextSize = containerSize * 0.875
            let qrCodeSize = containerSize * 0.625

            ZStack {
                if FeatureFlags.qrCodeCircularText {
                    CircularTextView(
                        phrase: Loc.connectWithMeOnAnytype,
                        size: circularTextSize
                    )
                }
                QRCodeDocumentUIView(document: document)
                    .frame(width: qrCodeSize, height: qrCodeSize)
            }
            .frame(width: containerSize, height: containerSize)
        }
        .aspectRatio(1, contentMode: .fit)
    }
}

#Preview {
    ProfileQRCodeView()
}
