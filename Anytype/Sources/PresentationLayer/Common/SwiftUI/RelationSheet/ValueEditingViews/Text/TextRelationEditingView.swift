import SwiftUI

struct TextRelationEditingView: View {
            
    @ObservedObject var viewModel: TextRelationEditingViewModel
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
                AnytypeText(viewModel.placeholder, style: .uxBodyRegular, color: .textTertiary)
                    .padding(6)
            }

            AutofocusedTextEditor(text: $viewModel.value, keyboardType: viewModel.keyboardType)
                .font(AnytypeFontBuilder.font(anytypeFont: .uxBodyRegular))
                .foregroundColor(.grayscale90)
                .opacity(viewModel.value.isEmpty ? 0.25 : 1)
                .frame(maxHeight: max(40, height))
        }
    }
    
}

struct RelationTextValueEditingView_Previews: PreviewProvider {
    static var previews: some View {
        TextRelationEditingView(
            viewModel: TextRelationEditingViewModel(
                service: TextRelationEditingService(
                    objectId: "",
                    valueType: .text
                ),
                key: "",
                value: nil
            )
        )
            .background(Color.red)
    }
}
