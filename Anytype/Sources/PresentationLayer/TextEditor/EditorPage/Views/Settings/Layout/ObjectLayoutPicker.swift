import SwiftUI
import BlocksModels


struct ObjectLayoutPicker: View {
    
    @ObservedObject var viewModel: ObjectLayoutPickerViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            TitleView(title: "Choose layout type".localized)
            layoutList
        }
        .background(Color.backgroundSecondary)
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
