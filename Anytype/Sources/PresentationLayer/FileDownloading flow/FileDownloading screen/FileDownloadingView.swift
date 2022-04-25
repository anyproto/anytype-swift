import SwiftUI

struct FileDownloadingView: View {
    
    @ObservedObject var viewModel: FileDownloadingViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            AnytypeText("Loading, please wait".localized, style: .uxCalloutRegular, color: .textPrimary)
            Spacer.fixedHeight(13)
            ProgressView(value: viewModel.bytesLoaded, total: viewModel.bytesExpected)
                .progressViewStyle(LinearProgressViewStyle(tint: .textPrimary))
                .scaleEffect(x: 1, y: 1.5, anchor: .center)
            Spacer.fixedHeight(20)
            button
            Spacer.fixedHeight(15)
        }
        .padding(.horizontal, 20)
        .background(Color.backgroundPrimary)
    }
    
    private var button: some View {
        Button {
            viewModel.didTapCancelButton()
        } label: {
            AnytypeText("Cancel".localized, style: .uxBodyRegular, color: .System.red)
        }
    }
    
}
