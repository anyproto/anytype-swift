import SwiftUI

struct SetFiltersTextView: View {
    let viewModel: SetFiltersTextViewModel
    @State private var input = ""
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer.fixedHeight(10)
            textField
            Spacer.fixedHeight(10)
            button
        }
        .padding(.horizontal, 20)
    }
    
    var textField: some View {
        AutofocusedTextField(
            placeholder: Loc.EditFilters.Popup.TextView.placeholder,
            text: $input
        )
        .keyboardType(viewModel.isDecimalPad ? .decimalPad : .default)
        .frame(height: 48)
        .divider()
    }
    
    private var button: some View {
        StandardButton(disabled: input.isEmpty, text: Loc.Set.Filters.Search.Button.title, style: .primary) {
            viewModel.handleText(input)
        }
        .padding(.top, 10)
    }
}
