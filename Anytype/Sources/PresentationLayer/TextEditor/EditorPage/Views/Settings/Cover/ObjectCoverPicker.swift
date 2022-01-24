import SwiftUI
import Amplitude


struct ObjectCoverPicker: View {
    
    @ObservedObject var viewModel: ObjectCoverPickerViewModel
    @Environment(\.presentationMode) private var presentationMode
    
    var onDismiss: () -> Void = {}
    
    @State private var selectedTab: Tab = .gallery
    
    var body: some View {
        VStack(spacing: 0) {
            switch selectedTab {
            case .gallery:
                galleryTabView
            case .upload:
                uploadTabView
            }
            
            tabHeaders
        }
    }
    
    private var galleryTabView: some View {
        VStack(spacing: 0) {
            DragIndicator(bottomPadding: 0)
            navigationBarView
            CoverColorsGridView { cover in
                switch cover {
                case let .color(color):
                    viewModel.setColor(color.name)
                case let .gradient(gradient):
                    viewModel.setGradient(gradient.name)
                }
                dismiss()
            }
        }
        .transition(
            .asymmetric(
                insertion: .move(edge: .leading),
                removal: .move(edge: .trailing)
            )
        )
    }
    
    private var uploadTabView: some View {
        MediaPickerView(contentType: viewModel.mediaPickerContentType) { itemProvider in
            itemProvider.flatMap {
                viewModel.uploadImage(from: $0)
            }
            dismiss()
        }
        .transition(
            .asymmetric(
                insertion: .move(edge: .trailing),
                removal: .move(edge: .leading)
            )
        )
    }
    
    private var navigationBarView: some View {
        InlineNavigationBar {
            AnytypeText("Change cover".localized, style: .uxTitle1Semibold, color: .textPrimary)
                .multilineTextAlignment(.center)
        } rightButton: {
            Button {
                viewModel.removeCover()
                dismiss()
            } label: {
                AnytypeText("Remove".localized, style: .uxBodyRegular, color: Color.System.red)
            }
        }
    }
    
    private var tabHeaders: some View {
        HStack {
            tabHeaderButton(.gallery)
            tabHeaderButton(.upload)
        }
        .frame(height: 48)
    }
    
    private func tabHeaderButton(_ tab: Tab) -> some View {
        Button {
            UISelectionFeedbackGenerator().selectionChanged()
            withAnimation {
                selectedTab = tab
            }
            
        } label: {
            AnytypeText(
                tab.title,
                style: .uxBodyRegular,
                color: selectedTab == tab ? Color.buttonSelected : Color.grayscale50
            )
        }
        .frame(maxWidth: .infinity)
    }
    
    private func dismiss() {
        presentationMode.wrappedValue.dismiss()
        onDismiss()
    }
}

// MARK: - Private extension

private extension ObjectCoverPicker {
    
    enum Tab: CaseIterable {
        case gallery
        case upload
        
        var title: String {
            switch self {
            case .gallery: return "Gallery".localized
            case .upload: return "Upload".localized
            }
        }
    }
    
}

