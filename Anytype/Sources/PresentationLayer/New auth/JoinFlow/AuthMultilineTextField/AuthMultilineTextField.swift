import SwiftUI

struct AuthMultilineTextField: View {
    @Binding var text: String
    @Binding var autofocus: Bool
    @Binding var blured: Bool

    init(text: Binding<String>, autofocus: Binding<Bool>, blured: Binding<Bool>) {
        self._text = text
        self._autofocus = autofocus
        self._blured = blured
    }
    
    var body: some View {
        Group {
            if #available(iOS 16.0, *) {
                TextField("", text: $text,  axis: .vertical)
                    .padding(Constants.edgeInsets)
                    .background(Color.Auth.input)
                    .blur(radius: blured ? 0 : Constants.blurRadius)
                    .cornerRadius(Constants.cornerRadius, style: .continuous)
            } else {
                TextEditor(text: $text)
                    .autofocus($autofocus)
                    .frame(height: 100)
                    .padding(Constants.edgeInsets)
                    .blur(radius: blured ? 0 : Constants.blurRadius)
                    .overlay(
                        RoundedRectangle(cornerRadius: Constants.cornerRadius)
                            .stroke(Color.Auth.input, lineWidth: 2)
                    )
            }
        }
        .autofocus($autofocus)
        .disableAutocorrection(true)
        .textContentType(.password)
        .autocapitalization(.none)
        .font(AnytypeFontBuilder.font(anytypeFont: .authInput))
        .foregroundColor(.Auth.inputText)
        .accentColor(.Auth.inputText)
        .lineSpacing(AnytypeFont.authInput.lineSpacing)
    }
}

extension AuthMultilineTextField {
    enum Constants {
        static let edgeInsets = EdgeInsets(horizontal: 22, vertical: 24)
        static let blurRadius: CGFloat = 5
        static let cornerRadius: CGFloat = 24
    }
}
