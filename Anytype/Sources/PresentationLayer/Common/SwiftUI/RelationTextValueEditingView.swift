import SwiftUI

struct RelationTextValueEditingView: View {
    @State var text: String = ""
    @State private var height: CGFloat = 0
    
    var body: some View {
        textEditingView
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
    }
    
    private var textEditingView: some View {
        ZStack(alignment: .leading) {
            Text(text)
                .font(AnytypeFontBuilder.font(anytypeFont: .uxBodyRegular))
                .opacity(0)
                .padding(6)
                .background(FrameCatcher { height = $0.height })
            
            if(text.isEmpty) {
                AnytypeText("Add text".localized, style: .uxBodyRegular, color: .textTertiary)
                    .padding(6)
            }

            AutofocusedTextEditor(text: $text)
                .font(AnytypeFontBuilder.font(anytypeFont: .uxBodyRegular))
                .foregroundColor(.grayscale90)
                .opacity(text.isEmpty ? 0.25 : 1)
                .frame(maxHeight: max(40, height))
        }
    }
}

struct TextValueRelationEditingView_Previews: PreviewProvider {
    static var previews: some View {
        RelationTextValueEditingView()
            .background(Color.red)
    }
}
