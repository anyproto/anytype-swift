import SwiftUI

struct FileDownloadingView: View {
    
    @ObservedObject var viewModel: FileDownloadingViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer.fixedHeight(15)
            AnytypeText("Loading, please wait".localized, style: .uxCalloutRegular, color: .textPrimary)
            Spacer.fixedHeight(13)
            ProgressView(value: viewModel.bytesLoaded, total: viewModel.bytesExpected)
                .progressViewStyle(LinearProgressViewStyle(tint: .textPrimary))
                .scaleEffect(x: 1, y: 1.5, anchor: .center)
            Spacer.fixedHeight(20)
        }
        .padding(.horizontal, 20)
        .background(Color.backgroundPrimary)
        .cornerRadius(16)
    }
    
}
