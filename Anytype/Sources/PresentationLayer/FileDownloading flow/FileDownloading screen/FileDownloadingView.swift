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
        .background(Color.backgroundSecondary)
    }
    
    private var errorView: some View {
        AnytypeText(viewModel.errorMessage, style: .body, color: .textPrimary)
            .if(size.isNotZero) {
                $0.frame(minHeight: size.height)
            }
    }
    
    private var loadingView: some View {
        VStack(spacing: 0) {
            AnytypeText(Loc.loadingPleaseWait, style: .uxCalloutRegular, color: .textPrimary)
            
            Spacer.fixedHeight(13)
            ProgressView(value: viewModel.bytesLoaded, total: viewModel.bytesExpected)
                .progressViewStyle(LinearProgressViewStyle(tint: .textPrimary))
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
            AnytypeText(Loc.cancel, style: .uxBodyRegular, color: .System.red)
        }
    }
    
    private var doneButton: some View {
        Button {
            viewModel.didTapDoneButton()
        } label: {
            AnytypeText(Loc.ok, style: .uxBodyRegular, color: .buttonAccent)
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
