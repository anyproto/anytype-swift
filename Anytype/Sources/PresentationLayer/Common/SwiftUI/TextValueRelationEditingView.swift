import SwiftUI

struct TextValueRelationEditingView: View {
    @State var text: String = ""
    @State private var height: CGFloat = 0
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            content
        }
        .padding(.bottom, -UIApplication.shared.mainWindowInsets.bottom)
    }
    
    private var content: some View {
        VStack(spacing: 0) {
            DragIndicator(bottomPadding: 0)
            AnytypeText("About".localized, style: .uxTitle1Semibold, color: .textPrimary)
                .padding([.top, .bottom], 12)
            
            textEditingView
            
            Spacer.fixedHeight(20 + UIApplication.shared.mainWindowInsets.bottom)
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
            
            TextEditor(text: $text)
                .font(AnytypeFontBuilder.font(anytypeFont: .uxBodyRegular))
                .foregroundColor(Color.grayscale90)
                .frame(maxHeight: max(40, height))
            
            AnytypeText("Add text", style: .uxBodyRegular, color: .textTertiary)
                .padding(6)
                .opacity(text.isEmpty ? 1 : 0)
        }
    }
}

struct TextValueRelationEditingView_Previews: PreviewProvider {
    static var previews: some View {
        TextValueRelationEditingView()
            .background(Color.red)
    }
}
