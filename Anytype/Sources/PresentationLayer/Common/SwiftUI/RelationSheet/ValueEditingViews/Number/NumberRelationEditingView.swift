import SwiftUI

struct NumberRelationEditingView: View {
            
    @ObservedObject var viewModel: NumberRelationEditingViewModel
    
    var body: some View {
        textEditingView
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
    }
    
    private var textEditingView: some View {
        ZStack(alignment: .leading) {
            if(viewModel.value.isEmpty) {
                AnytypeText("Add number".localized, style: .uxBodyRegular, color: .textTertiary)
                    .padding(6)
            }

            AutofocusedTextEditor(text: $viewModel.value, keyboardType: .decimalPad)
                .font(AnytypeFontBuilder.font(anytypeFont: .uxBodyRegular))
                .foregroundColor(.grayscale90)
                .opacity(viewModel.value.isEmpty ? 0.25 : 1)
                .frame(maxHeight: 40)
        }
    }
    
}

struct NumberRelationEditingView_Previews: PreviewProvider {
    static var previews: some View {
        NumberRelationEditingView(viewModel: NumberRelationEditingViewModel(objectId: "", relationKey: "", value: ""))
            .background(Color.red)
    }
}
