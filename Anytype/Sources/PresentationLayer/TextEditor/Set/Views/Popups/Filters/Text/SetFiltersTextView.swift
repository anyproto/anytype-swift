import SwiftUI

struct SetFiltersTextView: View {
    @ObservedObject var viewModel: SetFiltersTextViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer.fixedHeight(10)
            textField
            Spacer.fixedHeight(10)
            button
        }
        .padding(.horizontal, 20)
        .animation(.easeOut.speed(1.5))
    }
    
    var textField: some View {
        AutofocusedTextField(
            placeholder: Loc.EditSet.Popup.Filters.TextView.placeholder,
            placeholderFont: .uxBodyRegular,
            text: $viewModel.input
        )
        .foregroundColor(.Text.primary)
        .font(AnytypeFontBuilder.font(anytypeFont: .uxBodyRegular))
        .keyboardType(viewModel.keyboardType)
        .frame(height: 48)
        .divider()
    }
    
    private var button: some View {
        StandardButton(Loc.Set.Button.Title.apply, style: .primaryLarge) {
            viewModel.handleText()
        }
        .disabled(viewModel.input.isEmpty)
        .padding(.top, 10)
    }
}
