import SwiftUI
import BlocksModels


struct ObjectLayoutPicker: View {
    
    @ObservedObject var viewModel: ObjectLayoutPickerViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            TitleView(title: Loc.chooseLayoutType)
            layoutList
        }
        .background(Color.BackgroundNew.secondary)
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
