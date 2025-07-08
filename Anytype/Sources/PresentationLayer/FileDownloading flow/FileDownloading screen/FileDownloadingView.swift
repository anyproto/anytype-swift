import SwiftUI

struct FileDownloadingView: View {
    
    @ObservedObject var viewModel: FileDownloadingViewModel
        
    @State private var size: CGSize = .zero
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                if viewModel.isErrorOccured {
                    errorView
                } else {
                    loadingView
                }
            }
            Spacer.fixedHeight(20)
            button
            Spacer.fixedHeight(15)
        }
        .padding(.horizontal, 20)
        .background(Color.Background.secondary)
    }
    
    private var errorView: some View {
        AnytypeText(viewModel.errorMessage, style: .bodyRegular)
                .foregroundColor(.Text.primary)
            .if(size.isNotZero) {
                $0.frame(minHeight: size.height)
            }
    }
    
    private var loadingView: some View {
        VStack(spacing: 0) {
            AnytypeText(Loc.loadingPleaseWait, style: .uxCalloutRegular)
                .foregroundColor(.Text.primary)
            
            Spacer.fixedHeight(13)
            ProgressView(value: viewModel.bytesLoaded, total: viewModel.bytesExpected)
                .progressViewStyle(LinearProgressViewStyle(tint: .Text.primary))
                .scaleEffect(x: 1, y: 1.5, anchor: .center)
        }
        .readSize { size in
            self.size = size
        }
    }
    
    private var button: some View {
        Group {
            if viewModel.isErrorOccured {
                doneButton
            } else {
                cancelButton
            }
        }
    }
    private var cancelButton: some View {
        Button {
            viewModel.didTapCancelButton()
        } label: {
            AnytypeText(Loc.cancel, style: .uxBodyRegular)
                .foregroundColor(.Pure.red)
        }
    }
    
    private var doneButton: some View {
        Button {
            viewModel.didTapDoneButton()
        } label: {
            AnytypeText(Loc.ok, style: .uxBodyRegular)
                .foregroundColor(.Control.accent100)
        }
    }
     
}

struct FileDownloadingView_Previews: PreviewProvider {
    
    final class FileDownloadingModuleOutputMock: FileDownloadingModuleOutput {
        func didDownloadFileTo(_ url: URL) {

        }
        
        func didAskToClose() {
            
        }
        
    }
    
    static var previews: some View {
        FileDownloadingView(
            viewModel: FileDownloadingViewModel(
                url: URL(string: "https")!,
                output: FileDownloadingModuleOutputMock()
            )
        )
    }
}
