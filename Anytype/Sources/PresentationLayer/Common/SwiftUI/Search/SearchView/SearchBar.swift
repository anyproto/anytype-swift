import SwiftUI

struct SearchBar: View {
    @Binding var text: String
    let focused: Bool
    var placeholder: String = "Search"

    var body: some View {
        Group {
            if focused {
                AutofocusedTextField(placeholder: placeholder.localized, text: $text)
            } else {
                AnytypeTextField(placeholder: placeholder.localized, text: $text)
            }
        }
        .padding(8)
        .padding(.horizontal, 25)
        .font(AnytypeFontBuilder.font(anytypeFont: .uxBodyRegular))
        .background(Color.backgroundSelected)
        .cornerRadius(10)
        .overlay(overlay)
        .padding(.horizontal, 16)
        .padding(.vertical, 6)
    }
    
    private var overlay: some View {
        HStack() {
            Image.SearchBar.magnifyingGlass
                .renderingMode(.template)
                .aspectRatio(contentMode: .fit)
                .foregroundColor(.buttonActive)
                .frame(width: 14, height: 14)
                .padding(.leading, 11)
            
            Spacer()
            
            if !text.isEmpty {
                Button(action: { text = "" }) {
                    Image.SearchBar.circleFill
                        .renderingMode(.template)
                        .foregroundColor(.buttonActive)
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
