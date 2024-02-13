import SwiftUI


/*
 There is no way to change the keyboard toolbar style now
 and HStack doesn't work inside ToolbarItemGroup,
 so this special construction helps us to set needed background color in toolbar
 */
struct KeyboardToolbarView: View {
    var body: some View {
        Color.Background.primary
            .overlay(alignment: .trailing, content: {
                Button(action: {
                    UIApplication.shared.hideKeyboard()
                }) {
                    AnytypeText(Loc.done, style: .uxBodyRegular, color: .Text.primary)
                }
                .padding(.trailing, 10)
            })
            .padding(.horizontal, -16)
            .frame(height: UIDevice.isPad ? 56 : 45)
    }
}
