import SwiftUI

struct AuthMultilineTextField: View {
    @Binding var text: String
    @Binding var showText: Bool

    init(text: Binding<String>, showText: Binding<Bool>) {
        self._text = text
        self._showText = showText
    }
    
    var body: some View {
        Group {
            if #available(iOS 16.0, *) {
                TextField(Loc.Auth.LoginFlow.Textfield.placeholder, text: $text,  axis: .vertical)
                    .lineLimit(4, reservesSpace: true)
                    .padding(Constants.edgeInsets)
                    .background(Color.Stroke.transperent)
                    .blur(radius: showText ? 0 : Constants.blurRadius)
                    .cornerRadius(Constants.cornerRadius, style: .continuous)
                    .opacity(0.8)
            } else {
                TextEditor(text: $text)
                    .frame(height: 105)
                    .padding(Constants.edgeInsets)
                    .blur(radius: showText ? 0 : Constants.blurRadius)
                    .overlay(
                        RoundedRectangle(cornerRadius: Constants.cornerRadius)
                            .stroke(Color.Stroke.transperent, lineWidth: 2)
                    )
            }
        }
        .disableAutocorrection(true)
        .textContentType(.password)
        .autocapitalization(.none)
        .font(AnytypeFontBuilder.font(anytypeFont: .authInput))
        .foregroundColor(.Auth.inputText)
        .accentColor(.Auth.inputText)
        .lineSpacing(AnytypeFont.authInput.lineSpacing)
        .autocapitalization(.none)
        .textContentType(.password)
        .disableAutocorrection(true)
    }
}

extension AuthMultilineTextField {
    enum Constants {
        static let edgeInsets = EdgeInsets(horizontal: 22, vertical: 24)
        static let blurRadius: CGFloat = 5
        static let cornerRadius: CGFloat = 24
    }
}
