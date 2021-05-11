import SwiftUI

struct NavigationButtonView: View {
    @Binding var disabled: Bool
    var text: String
    var style: StandardButtonStyle
    
    var body: some View {
        AnytypeText(text, style: .heading)
            .padding(.all)
            .foregroundColor(disabled ? .textSecondary : style.textColor())
            .frame(minWidth: 0, maxWidth: .infinity)
            .background(style.backgroundColor())
            .cornerRadius(7)
            .disabled(disabled)
    }
}

struct NavigationButtonView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationButtonView(disabled: .constant(false), text: "Navigation Button", style: .yellow)
    }
}
