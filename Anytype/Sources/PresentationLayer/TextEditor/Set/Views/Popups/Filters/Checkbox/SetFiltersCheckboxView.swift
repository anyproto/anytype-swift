import SwiftUI

struct SetFiltersCheckboxView: View {
    @StateObject private var viewModel: SetFiltersCheckboxViewModel
    
    init(filter: SetFilter, onApplyCheckbox: @escaping (Bool) -> Void) {
        _viewModel = StateObject(wrappedValue: SetFiltersCheckboxViewModel(filter: filter, onApplyCheckbox: onApplyCheckbox))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer.fixedHeight(10)
            rows
            button
        }
        .padding(.horizontal, 20)
        .background(Color.Background.secondary)
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
                style: .uxBodyRegular
            )
            .foregroundColor(.Text.primary)
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
        Image(asset: .X24.tick)
            .foregroundColor(.Control.primary)
    }
    
    private var button: some View {
        StandardButton(Loc.apply, style: .primaryLarge) {
            viewModel.handleCheckbox()
        }
        .padding(.top, 20)
    }
}
