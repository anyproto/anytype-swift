import SwiftUI
import Services

struct ObjectLayoutPicker: View {

    @State private var viewModel: ObjectLayoutPickerViewModel
    @Environment(\.dismiss) private var dismiss

    init(mode: ObjectLayoutPickerMode, objectId: String, spaceId: String, analyticsType: AnalyticsObjectType) {
        _viewModel = State(initialValue: ObjectLayoutPickerViewModel(mode: mode, objectId: objectId, spaceId: spaceId, analyticsType: analyticsType))
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
                        dismiss()
                    }
                )
            }
        }
    }
}
