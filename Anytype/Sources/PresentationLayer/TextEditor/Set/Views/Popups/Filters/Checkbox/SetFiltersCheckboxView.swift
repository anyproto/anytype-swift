import SwiftUI

struct SetFiltersCheckboxView: View {
    @ObservedObject var viewModel: SetFiltersCheckboxViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer.fixedHeight(10)
            rows
            button
        }
        .padding(.horizontal, 20)
    }
    
    private var rows: some View {
        VStack(spacing: 0) {
            ForEach(SetFiltersCheckboxState.allCases) { state in
                Button {
                    viewModel.changeState()
                } label: {
                    row(for: state)
                }
                .divider()
            }
        }
    }
    
    private func row(for state: SetFiltersCheckboxState) -> some View {
        HStack(spacing: 0) {
            AnytypeText(
                state.title,
                style: .uxBodyRegular,
                color: .textPrimary
            )
            Spacer()
            icon(for: state)
        }
        .frame(height: 48)
    }
    
    private func icon(for state: SetFiltersCheckboxState) -> some View {
        Group {
            if state == viewModel.state {
                Image.optionChecked
                    .frame(width: 24, height: 24)
                    .foregroundColor(.buttonSelected)
            } else {
                EmptyView()
            }
        }
    }
    
    private var button: some View {
        StandardButton(disabled: false, text: Loc.Set.Filters.Search.Button.title, style: .primary) {
            viewModel.handleCheckbox()
        }
        .padding(.top, 20)
    }
}
