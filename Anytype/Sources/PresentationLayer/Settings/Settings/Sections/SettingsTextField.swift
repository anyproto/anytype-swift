import SwiftUI

struct SettingsTextField: View {
    
    let title: String
    @Binding var text: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            AnytypeText(title, style: .caption1Regular)
                .foregroundColor(.Text.secondary)
            AnytypeTextField(placeholder: Loc.Object.Title.placeholder, placeholderFont: .heading, text: $text)
                .foregroundColor(.Text.primary)
                .font(AnytypeFontBuilder.font(anytypeFont: .heading))
                .autocorrectionDisabled()
        }
        .padding(.vertical, 11)
        .newDivider()
    }
}

struct SettingsTextField_Previews: PreviewProvider {
    static var previews: some View {
        SettingsTextField(title: "Name", text: .constant("Personal"))
    }
}
