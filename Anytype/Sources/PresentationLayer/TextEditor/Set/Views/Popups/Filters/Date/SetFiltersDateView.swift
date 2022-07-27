import SwiftUI

struct SetFiltersDateView: View {
    @ObservedObject var viewModel: SetFiltersDateViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer.fixedHeight(10)
            rows
            button
        }
        .padding(.horizontal, 20)
    }
    
    private var rows: some View {
        ScrollView {
            VStack(spacing: 0) {
                ForEach(viewModel.rows) { configuration in
                    Button {
                        configuration.onTap()
                    } label: {
                        row(for: configuration)
                    }
                    .divider()
                }
            }
        }
    }
    
    private func row(for configuration: SetFiltersDateRowConfiguration) -> some View {
        HStack(spacing: 0) {
            AnytypeText(
                configuration.title,
                style: .uxBodyRegular,
                color: .textPrimary
            )
            Spacer()
            if configuration.isChecked {
                icon
            }
        }
        .frame(height: 48)
    }
    
    private var icon: some View {
        Image.optionChecked
            .frame(width: 24, height: 24)
            .foregroundColor(.buttonSelected)
    }
    
    private var button: some View {
        StandardButton(disabled: false, text: Loc.Set.Filters.Search.Button.title, style: .primary) {
            viewModel.handleDate()
        }
        .padding(.top, 20)
    }
}
