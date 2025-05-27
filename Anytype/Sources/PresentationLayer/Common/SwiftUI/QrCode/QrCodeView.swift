import Foundation
import SwiftUI
import QRCode

struct QrCodeView: View {
    
    @StateObject private var model: QrCodeViewModel
    
    init(title: String, data: String, analyticsType: ScreenQrAnalyticsType) {
        self._model = StateObject(wrappedValue: QrCodeViewModel(title: title, data: data, analyticsType: analyticsType))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            DragIndicator()
            Spacer.fixedHeight(15)
            AnytypeText(model.title, style: .heading)
                .foregroundColor(.Text.primary)
            Spacer.fixedHeight(20)
            QRCodeDocumentUIView(document: model.document)
                .frame(width: 200, height: 200)
            Spacer.fixedHeight(30)
            StandardButton(Loc.share, style: .secondaryLarge) {
                model.onShare()
            }
            Spacer.fixedHeight(16)
        }
        .padding(.horizontal, 20)
        .background(Color.Background.primary)
        .sheet(item: $model.sharedData) { data in
            ActivityView(activityItems: [data.value])
        }
        .onAppear {
            model.onAppear()
        }
    }
}

#Preview {
    QrCodeView(
        title: "Title",
        data: "https://invite.any.coop/bafybeidswywdqat64gupwpnrec12avv5yfhdbmit2skkfyv65stapd42me#D9QJW8SjXBT7QNb6yqfYE7ByggGrunwyNqMMjktKcK3b",
        analyticsType: .inviteSpace
    )
}
