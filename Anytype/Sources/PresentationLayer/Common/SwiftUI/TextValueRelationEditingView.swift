import SwiftUI

struct TextValueRelationEditingView: View {
    @State var text: String = ""
    @State private var height: CGFloat = 0
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            content
        }
        .ignoresSafeArea(.container)
    }
    
    private var content: some View {
        VStack(spacing: 0) {
            DragIndicator(bottomPadding: 0)
            AnytypeText("About".localized, style: .uxTitle1Semibold, color: .textPrimary)
                .padding([.top, .bottom], 12)
            
            textEditingView
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
            
            Spacer.fixedHeight(20)
        }
        .background(Color.background)
        .cornerRadius(16, corners: [.topLeft, .topRight])
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
        TextValueRelationEditingView()
            .background(Color.red)
    }
}
