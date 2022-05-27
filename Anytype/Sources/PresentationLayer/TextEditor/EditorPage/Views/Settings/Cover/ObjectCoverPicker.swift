import SwiftUI

struct ObjectCoverPicker: View {
    
    @ObservedObject var viewModel: ObjectCoverPickerViewModel
    @Environment(\.presentationMode) private var presentationMode
    
    var onDismiss: () -> Void = {}
    
    @State private var index: Int = 0
    
    var body: some View {
        TabView(selection: $index) {
            galleryTabView
                .tag(Tab.gallery.rawValue)
            unsplashView
                .tag(Tab.unsplash.rawValue)
            uploadTabView
                .tag(Tab.upload.rawValue)
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        tabHeaders
    }

    private var unsplashView: some View {
        VStack(spacing: 0) {
            DragIndicator()
            navigationBarView
            ItemPickerGridView(
                viewModel: UnsplashViewModel(
                    onItemSelect: { item in
                        viewModel.uploadUnplashCover(unsplashItem: item)
                        dismiss()
                    },
                    unsplashService: UnsplashService()
                )
            )
        }
    }

    
    private var galleryTabView: some View {
        VStack(spacing: 0) {
            DragIndicator()
            navigationBarView
            ItemPickerGridView(viewModel: CoverColorsGridViewModel { cover in
                    switch cover {
                    case let .color(color):
                        viewModel.setColor(color.data.name)
                    case let .gradient(gradient):
                        viewModel.setGradient(gradient.data.name)
                    }
                    dismiss()
                }
            )
        }
    }
    
    private var uploadTabView: some View {
        MediaPickerView(contentType: viewModel.mediaPickerContentType) { itemProvider in
            itemProvider.flatMap {
                viewModel.uploadImage(from: $0)
            }
            dismiss()
        }
    }
    
    private var navigationBarView: some View {
        InlineNavigationBar {
            AnytypeText("Change cover".localized, style: .uxTitle1Semibold, color: .textPrimary)
                .multilineTextAlignment(.center)
        } rightButton: {
            if viewModel.isRemoveButtonAvailable {
                Button {
                    viewModel.removeCover()
                    dismiss()
                } label: {
                    AnytypeText("Remove".localized, style: .uxBodyRegular, color: Color.System.red)
                }
            } else {
                EmptyView()
            }
        }
    }
    
    private var tabHeaders: some View {
        HStack {
            tabHeaderButton(.gallery)
            tabHeaderButton(.unsplash)
            tabHeaderButton(.upload)
        }
        .frame(height: 48)
    }
    
    private func tabHeaderButton(_ tab: Tab) -> some View {
        Button {
            UISelectionFeedbackGenerator().selectionChanged()
            withAnimation {
                index = tab.rawValue
            }
        } label: {
            AnytypeText(
                tab.title,
                style: .uxBodyRegular,
                color: index == tab.rawValue ? Color.buttonSelected : Color.buttonActive
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

    enum Tab: Int {
        case gallery
        case unsplash
        case upload

        var title: String {
            switch self {
            case .gallery: return "Gallery".localized
            case .unsplash: return "Unsplash".localized
            case .upload: return "Upload".localized
            }
        }
    }
}
