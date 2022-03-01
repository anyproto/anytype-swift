import SwiftUI
import BlocksModels


struct ObjectLayoutPicker: View {
    
    @ObservedObject var viewModel: ObjectLayoutPickerViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            TitleView(title: "Choose layout type".localized)
            layoutList
        }
        .padding(.bottom, 44)
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

struct DocumentLayoutPicker_Previews: PreviewProvider {
    static var previews: some View {
        ObjectLayoutPicker(viewModel: ObjectLayoutPickerViewModel(
            detailsService: DetailsService(objectId: "")
        ))
    }
}
