import SwiftUI

struct SearchBar: View {
    @Binding var text: String
    let focused: Bool
    var placeholder: String = Loc.search

    var body: some View {
        Group {
            if focused {
                AutofocusedTextField(placeholder: placeholder, font: .uxBodyRegular, text: $text)
                    .disableAutocorrection(true)
                    .autocapitalization(.none)
            } else {
                AnytypeTextField(placeholder: placeholder, font: .uxBodyRegular, text: $text)
                    .disableAutocorrection(true)
                    .autocapitalization(.none)
            }
        }
        .padding(8)
        .padding(.horizontal, 25)
        .background(Color.Background.highlightedMedium)
        .cornerRadius(10)
        .overlay(overlay)
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .divider()
    }
    
    private var overlay: some View {
        HStack() {
            Image(asset: .X18.search)
                .foregroundColor(.Control.active)
                .padding(.leading, 9)
            
            Spacer()
            
            if !text.isEmpty {
                Button(action: { text = "" }) {
                    Image(asset: .multiplyCircleFill)
                        .renderingMode(.template)
                        .foregroundColor(.Control.active)
                        .padding(.trailing, 8)
                }
            }
            
        }
    }
}

struct SearchBar_Previews: PreviewProvider {
    static var previews: some View {
        SearchBar(text: .constant(""), focused: true)
    }
}
