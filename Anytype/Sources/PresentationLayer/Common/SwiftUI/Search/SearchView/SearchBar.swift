import SwiftUI

struct SearchBar: View {
    @Binding var text: String
    let focused: Bool
    var placeholder: String = Loc.search

    var body: some View {
        Group {
            if focused {
                AutofocusedTextField(placeholder: placeholder, text: $text)
                    .disableAutocorrection(true)
            } else {
                AnytypeTextField(placeholder: placeholder, text: $text)
                    .disableAutocorrection(true)
            }
        }
        .padding(8)
        .padding(.horizontal, 25)
        .font(AnytypeFontBuilder.font(anytypeFont: .uxBodyRegular))
        .background(Color.backgroundSelected)
        .cornerRadius(10)
        .overlay(overlay)
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .divider()
    }
    
    private var overlay: some View {
        HStack() {
            Image(asset: .searchTextFieldIcon)
                .renderingMode(.template)
                .aspectRatio(contentMode: .fit)
                .foregroundColor(.buttonActive)
                .frame(width: 14, height: 14)
                .padding(.leading, 11)
            
            Spacer()
            
            if !text.isEmpty {
                Button(action: { text = "" }) {
                    Image(systemAsset: .multiplyCircleFill)
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
