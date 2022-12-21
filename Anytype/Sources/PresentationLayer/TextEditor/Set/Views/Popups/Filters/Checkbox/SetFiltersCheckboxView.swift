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
            ForEach(SetFiltersCheckboxValue.allCases) { value in
                Button {
                    viewModel.changeState(with: value)
                } label: {
                    row(for: value)
                }
                .divider()
            }
        }
    }
    
    private func row(for value: SetFiltersCheckboxValue) -> some View {
        HStack(spacing: 0) {
            AnytypeText(
                value.title,
                style: .uxBodyRegular,
                color: .textPrimary
            )
            Spacer()
            icon(for: value)
        }
        .frame(height: 48)
    }
    
    private func icon(for value: SetFiltersCheckboxValue) -> some View {
        Group {
            if viewModel.value == value {
                icon
            } else {
                EmptyView()
            }
        }
    }
    
    private var icon: some View {
        Image(asset: .optionChecked)
            .frame(width: 24, height: 24)
            .foregroundColor(.Button.selected)
    }
    
    private var button: some View {
        StandardButton(disabled: false, text: Loc.Set.Button.Title.apply, style: .primary) {
            viewModel.handleCheckbox()
        }
        .padding(.top, 20)
    }
}
