import SwiftUI

struct ViewHeightKey: PreferenceKey {
    static var defaultValue: CGFloat = 50

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

struct TextValueRelationEditingView: View {
    @State var text: String = ""
    @State private var height: CGFloat = .zero
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            VStack(spacing: 0) {
                DragIndicator(bottomPadding: 0)
                AnytypeText("About".localized, style: .uxTitle1Semibold, color: .textPrimary)
                    .padding([.top, .bottom], 12)
                ZStack(alignment: .leading) {
                    Text(text).foregroundColor(.clear).padding(6)
                        .background(GeometryReader {
                            Color.clear.preference(key: ViewHeightKey.self, value: $0.frame(in: .local).size.height)
                        })
                    TextEditor(text: $text)
                        .frame(maxHeight: height)
                    //.border(Color.red)        // << for testing
                }
                .onPreferenceChange(ViewHeightKey.self) { height = $0 }
            }
            .background(Color.background)
            .cornerRadius(16, corners: [.topLeft, .topRight])
        }
    }
}

struct TextValueRelationEditingView_Previews: PreviewProvider {
    static var previews: some View {
        TextValueRelationEditingView()
            .background(Color.red)
    }
}
