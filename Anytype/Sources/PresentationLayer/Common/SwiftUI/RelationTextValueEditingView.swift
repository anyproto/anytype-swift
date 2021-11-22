import SwiftUI

struct RelationTextValueEditingView: View, RelationValueEditingViewModelProtocol {
    
    let title = "About".localized
    
    @ObservedObject var viewModel: RelationTextValueEditingViewModel
    @State private var height: CGFloat = 0
    
    var body: some View {
        textEditingView
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
    }
    
    private var textEditingView: some View {
        ZStack(alignment: .leading) {
            Text(viewModel.value)
                .font(AnytypeFontBuilder.font(anytypeFont: .uxBodyRegular))
                .opacity(0)
                .padding(6)
                .background(FrameCatcher { height = $0.height })
            
            if(viewModel.value.isEmpty) {
                AnytypeText("Add text".localized, style: .uxBodyRegular, color: .textTertiary)
                    .padding(6)
            }

            AutofocusedTextEditor(text: $viewModel.value)
                .font(AnytypeFontBuilder.font(anytypeFont: .uxBodyRegular))
                .foregroundColor(.grayscale90)
                .opacity(viewModel.value.isEmpty ? 0.25 : 1)
                .frame(maxHeight: max(40, height))
        }
    }
    
    func saveValue() {
        viewModel.saveValue()
    }
    
}

struct RelationTextValueEditingView_Previews: PreviewProvider {
    static var previews: some View {
        RelationTextValueEditingView(viewModel: RelationTextValueEditingViewModel(objectId: "", relationKey: "", value: ""))
            .background(Color.red)
    }
}
