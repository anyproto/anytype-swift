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
                TextField("", text: $text,  axis: .vertical)
                    .padding(Constants.edgeInsets)
                    .background(Color.Auth.input)
                    .blur(radius: showText ? 0 : Constants.blurRadius)
                    .cornerRadius(Constants.cornerRadius, style: .continuous)
            } else {
                TextEditor(text: $text)
                    .frame(height: 105)
                    .padding(Constants.edgeInsets)
                    .blur(radius: showText ? 0 : Constants.blurRadius)
                    .overlay(
                        RoundedRectangle(cornerRadius: Constants.cornerRadius)
                            .stroke(Color.Auth.input, lineWidth: 2)
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
    }
}

extension AuthMultilineTextField {
    enum Constants {
        static let edgeInsets = EdgeInsets(horizontal: 22, vertical: 24)
        static let blurRadius: CGFloat = 5
        static let cornerRadius: CGFloat = 24
    }
}
