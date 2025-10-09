import SwiftUI

struct SetTextViewData: Identifiable {
    let id = UUID().uuidString
    let title: String
    let text: String
    let onTextChanged: (String) -> Void
}

struct SetTextView: View {
    private let title: String
    private let onTextChanged: (String) -> Void
    
    @State private var text: String
    
    init(data: SetTextViewData) {
        title = data.title
        onTextChanged = data.onTextChanged
        text = data.text
    }
    
    var body: some View {
        VStack(spacing: 0) {
            TitleView(title: title)
            AutofocusedTextField(
                placeholder: Loc.EditSet.Popup.Filters.TextView.placeholder,
                font: .uxBodyRegular,
                text: $text
            )
            .frame(height: 48)
            .keyboardType(.decimalPad)
            .onChange(of: text) { _, text in
                onTextChanged(text)
            }
        }
        .padding(.horizontal, 20)
        .fitPresentationDetents()
        .background(Color.Background.secondary)
    }
}
