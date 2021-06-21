import SwiftUI

struct DocumentCoverPicker: View {
    
    @EnvironmentObject private var viewModel: DocumentCoverPickerViewModel
    @Environment(\.presentationMode) private var presentationMode
    
    @State private var selectedTab: Tab = .gallery
    
    var body: some View {
        VStack(spacing: 0) {
            switch selectedTab {
            case .gallery:
                galleryTab
            case .upload:
                uploadTab
            }
            
            tabHeaders
        }
    }
    
    private var galleryTab: some View {
        VStack(spacing: 0) {
            DragIndicator(bottomPadding: 0)
            navigationBarView
            CoverColorsGridView()
        }
        .transition(
            .asymmetric(
                insertion: .move(edge: .leading),
                removal: .move(edge: .trailing)
            )
        )
    }
    
    private var uploadTab: some View {
        MediaPickerView(contentType: viewModel.mediaPickerContentType) { itemProvider in
            // TODO: - implement
            debugPrint(itemProvider)
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
                // TODO: - implement
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

private extension DocumentCoverPicker {
    
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
        DocumentCoverPicker()
    }
}
