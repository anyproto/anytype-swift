import SwiftUI

struct ObjectCoverPicker: View {
    
    @EnvironmentObject private var viewModel: ObjectCoverPickerViewModel
    @Environment(\.presentationMode) private var presentationMode
    
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
                presentationMode.wrappedValue.dismiss()
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
            presentationMode.wrappedValue.dismiss()
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
            AnytypeText("Change cover", style: .headlineSemibold)
                .multilineTextAlignment(.center)
        } rightButton: {
            Button {
                viewModel.removeCover()
                presentationMode.wrappedValue.dismiss()
            } label: {
                AnytypeText("Remove", style: .headline)
                    .foregroundColor(.red)
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
            AnytypeText(tab.title, style: .headline)
                .foregroundColor(selectedTab == tab ? Color.buttonSelected : Color.buttonActive)
        }
        .frame(maxWidth: .infinity)
    }
    
}

// MARK: - Private extension

private extension ObjectCoverPicker {
    
    enum Tab: CaseIterable {
        case gallery
        case upload
        
        var title: String {
            switch self {
            case .gallery: return "Gallery"
            case .upload: return "Upload"
            }
        }
    }
    
}

struct DocumentCoverPicker_Previews: PreviewProvider {
    static var previews: some View {
        ObjectCoverPicker()
    }
}
