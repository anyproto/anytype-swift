import SwiftUI
import Services

struct ObjectCoverPicker: View {
    
    @StateObject private var viewModel: ObjectCoverPickerViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var index: Int = 0
    
    init(data: BaseDocumentIdentifiable) {
        self._viewModel = StateObject(wrappedValue: ObjectCoverPickerViewModel(data: data))
    }
    
    var body: some View {
        VStack {
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
        .background(Color.Background.primary)
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
                    }
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
            AnytypeText(Loc.changeCover, style: .uxTitle1Semibold)
                .foregroundColor(.Text.primary)
                .multilineTextAlignment(.center)
        } rightButton: {
            if viewModel.isRemoveButtonAvailable {
                Button {
                    viewModel.removeCover()
                    dismiss()
                } label: {
                    AnytypeText(Loc.remove, style: .uxBodyRegular)
                        .foregroundColor(.System.red)
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
                style: .uxBodyRegular
            )
            .foregroundColor(index == tab.rawValue ? Color.Control.button : Color.Control.active)
        }
        .frame(maxWidth: .infinity)
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
            case .gallery: return Loc.gallery
            case .unsplash: return Loc.unsplash
            case .upload: return Loc.upload
            }
        }
    }
}
