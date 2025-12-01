import SwiftUI
import QRCode

struct ProfileQRCodeView: View {

    @StateObject private var model = ProfileQRCodeViewModel()

    var body: some View {
        content
            .background(Color.Background.primary)
            .sheet(item: $model.sharedData) { data in
                ActivityView(activityItems: [data.value])
            }
            .snackbar(toastBarData: $model.toastBarData)
            .onAppear {
                model.onAppear()
            }
    }

    @ViewBuilder
    private var content: some View {
        switch model.state {
        case .loading:
            EmptyView()
        case .error:
            EmptyStateView(
                title: Loc.error,
                style: .error
            )
        case .loaded(let document):
            loadedContent(document: document)
        }
    }

    private func loadedContent(document: QRCode.Document) -> some View {
        VStack(spacing: 0) {
            DragIndicator()
            Spacer.fixedHeight(12)
            AnytypeText(model.anyName, style: .uxBodyRegular)
                .foregroundColor(.Text.primary)
            Spacer.fixedHeight(24)
            QRCodeDocumentUIView(document: document)
                .frame(width: 200, height: 200)
            Spacer.fixedHeight(32)
            StandardButton(Loc.share, style: .primaryLarge) {
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
}

#Preview {
    ProfileQRCodeView()
}
