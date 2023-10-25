import SwiftUI

struct SetTextView: View {
    @StateObject var model: SetTextViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            TitleView(title: model.title)
            AutofocusedTextField(
                placeholder: Loc.EditSet.Popup.Filters.TextView.placeholder,
                placeholderFont: .uxBodyRegular,
                text: $model.text
            )
            .frame(height: 48)
            .keyboardType(.decimalPad)
        }
        .padding(.horizontal, 20)
        .fitPresentationDetents()
        .background(Color.Background.secondary)
    }
}
