import SwiftUI

struct AnytypeTextField: View {
    let placeholder: String
    let placeholderFont: AnytypeFont
    @Binding var text: String
    
    @State private var textFieldHeight: CGFloat = 0
    
    var body: some View {
        ZStack(alignment: .leading) {
            if text.isEmpty {
                AnytypeText(placeholder, style: placeholderFont, color: .textTertiary)
            }
            TextField("", text: $text)
                .readSize {
                    textFieldHeight = $0.height
                }
        }
        .frame(height: textFieldHeight)
    }
}

struct AnytypeTextField_Previews: PreviewProvider {
    @State static var text: String = "text"
    static var previews: some View {
        AnytypeTextField(placeholder: "place", placeholderFont: .uxBodyRegular, text: $text)
            .background(Color.yellow)
    }
}
