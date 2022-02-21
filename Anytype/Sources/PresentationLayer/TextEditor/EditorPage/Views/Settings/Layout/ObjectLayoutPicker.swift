import SwiftUI
import BlocksModels


struct ObjectLayoutPicker: View {
    
    let viewModel: ObjectLayoutPickerViewModel
    
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            AnytypeText("Choose layout type".localized, style: .uxTitle1Semibold, color: .textPrimary)
                .padding([.top, .bottom], 12)
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
        .padding([.leading, .trailing], 20)
        .padding(.bottom, UIApplication.shared.mainWindowInsets.bottom + 20)
    }
}

struct DocumentLayoutPicker_Previews: PreviewProvider {
    static var previews: some View {
        ObjectLayoutPicker(viewModel: ObjectLayoutPickerViewModel(
            detailsService: DetailsService(objectId: "")
        ))
    }
}
