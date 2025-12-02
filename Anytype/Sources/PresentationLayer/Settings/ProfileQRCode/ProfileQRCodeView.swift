import SwiftUI
import QRCode
import Assets
import Services

struct ProfileQRCodeView: View {

    @StateObject private var model = ProfileQRCodeViewModel()

    var body: some View {
        content
            .sheet(item: $model.sharedData) { data in
                ActivityView(activityItems: [data.value])
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
            case .loaded(let document):
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
            StandardButton(Loc.shareQRCode, style: .primaryLarge) {
                model.onShare()
            }
            Spacer.fixedHeight(12)
            StandardButton(Loc.download, style: .secondaryLarge) {
                model.onDownload()
            }
            Spacer.fixedHeight(16)
        }
        .padding(.horizontal, 20)
    }

    private var headerRow: some View {
        HStack {
            Color.clear.frame(width: 44, height: 44)
            Spacer()
            HStack(spacing: 6) {
                IconView(icon: model.profileIcon)
                    .frame(width: 18, height: 18)
                AnytypeText(model.anyName.isEmpty ? Loc.qrCode : model.anyName, style: .caption1Medium)
                    .foregroundColor(.Text.primary)
            }
            Spacer()
            Button { model.onScanTap() } label: {
                Image(systemName: "qrcode.viewfinder")
                    .resizable()
                    .frame(width: 18, height: 18)
                    .foregroundColor(.Text.primary)
            }
            .frame(width: 18, height: 18)
        }
    }

    private func qrCodeWithCircularText(document: QRCode.Document) -> some View {
        GeometryReader { geometry in
            let containerSize = min(geometry.size.width, geometry.size.height)
            let circularTextSize = containerSize * 0.875
            let qrCodeSize = containerSize * 0.625

            ZStack {
                CircularTextView(
                    phrase: Loc.connectWithMeOnAnytype,
                    size: circularTextSize
                )
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
