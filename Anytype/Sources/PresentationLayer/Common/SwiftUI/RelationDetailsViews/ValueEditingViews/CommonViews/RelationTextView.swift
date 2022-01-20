import SwiftUI

struct RelationTextView: View {
    
    @Binding var text: String
    let placeholder: String
    let keyboardType: UIKeyboardType
    
    @State private var height: CGFloat = 0
    
    var body: some View {
        ZStack(alignment: .leading) {
            Text(text)
                .font(AnytypeFontBuilder.font(anytypeFont: .uxBodyRegular))
                .opacity(0)
                .padding(6)
                .readSize { height = $0.height }
            
            if(text.isEmpty) {
                AnytypeText(placeholder, style: .uxBodyRegular, color: .textTertiary)
                    .padding(6)
            }
            
            textView
        }
    }
    
    private var textView: some View {
        AutofocusedTextEditor(text: $text, keyboardType: keyboardType)
            .font(AnytypeFontBuilder.font(anytypeFont: .uxBodyRegular))
            .foregroundColor(.grayscale90)
            .opacity(text.isEmpty ? 0.25 : 1)
            .frame(maxHeight: max(40, height))
    }
}

struct RelationTextView_Previews: PreviewProvider {
    static var previews: some View {
        RelationTextView(text: .constant("1"), placeholder: "d", keyboardType: .numberPad)
    }
}
