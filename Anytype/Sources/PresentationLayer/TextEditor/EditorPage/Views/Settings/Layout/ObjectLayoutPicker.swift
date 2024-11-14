import SwiftUI
import Services

struct ObjectLayoutPicker: View {
    
    @StateObject private var viewModel: ObjectLayoutPickerViewModel
    
    init(mode: ObjectLayoutPickerMode, objectId: String, spaceId: String) {
        self._viewModel = StateObject(wrappedValue: ObjectLayoutPickerViewModel(mode: mode, objectId: objectId, spaceId: spaceId))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            DragIndicator()
            TitleView(title: Loc.chooseLayoutType)
            layoutList
        }
        .task {
            await viewModel.startDocumentSubscription()
        }
        .background(Color.Background.secondary)
        .fitPresentationDetents()
    }
    
    private var layoutList: some View {
        VStack(spacing: 0) {
            ForEach(DetailsLayout.editorLayouts, id: \.self) { layout in
                ObjectLayoutRow(
                    layout: layout,
                    isSelected: layout == viewModel.selectedLayout,
                    onTap: {
                        viewModel.didSelectLayout(layout)
                    }
                )
            }
        }
    }
}
