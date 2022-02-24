import SwiftUI

struct AnytypeTextField: View {
    
    let placeholder: String
    @Binding var text: String
    
    @State private var textFieldHeight: CGFloat = 0
    
    var body: some View {
        ZStack(alignment: .leading) {
            if text.isEmpty {
                AnytypeText(placeholder, style: .uxBodyRegular, color: .buttonActive)
            }
            TextField("", text: $text)
                .foregroundColor(.textPrimary)
                .font(AnytypeFontBuilder.font(anytypeFont: .uxBodyRegular))
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
        AnytypeTextField(placeholder: "place", text: $text)
            .background(Color.yellow)
    }
}
