import SwiftUI

struct SearchBar: View {
    @Binding var text: String
    let focused: Bool
    var placeholder: String = Loc.search
    var shouldShowDivider = true

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
        .clipShape(.rect(cornerRadius: 10))
        .overlay(alignment: .leading) {
            Image(asset: .X18.search)
                .foregroundStyle(Color.Control.secondary)
                .padding(.leading, 9)
        }
        .overlay(alignment: .trailing) {
            Button {
                text = ""
            } label: {
                Image(asset: .multiplyCircleFill)
                    .renderingMode(.template)
                    .foregroundStyle(Color.Control.secondary)
                    .padding(.trailing, 8)
                    .fixTappableArea()
            }
            .buttonStyle(.plain)
            .opacity(text.isEmpty ? 0 : 1)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .if(shouldShowDivider) {
            $0.divider()
        }
    }
}

struct SearchBar_Previews: PreviewProvider {
    static var previews: some View {
        SearchBar(text: .constant(""), focused: true)
    }
}
