import SwiftUI

struct SetFiltersDateView: View {
    @StateObject var viewModel: SetFiltersDateViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer.fixedHeight(10)
            rows
            button
        }
        .padding(.horizontal, 20)
        .sheet(isPresented: $viewModel.showFiltersDaysView) {
            viewModel.filtersDaysView()
        }
        .background(Color.Background.secondary)
    }
    
    private var rows: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 0) {
                ForEach(viewModel.rows) { configuration in
                    row(for: configuration)
                        .divider()
                }
            }
        }
    }
    
    private func row(for configuration: SetFiltersDateRowConfiguration) -> some View {
        SetFiltersDateRowView(configuration: configuration, date: $viewModel.date)
        .frame(height: 48)
    }
    
    private var button: some View {
        Group {
            let disabled = viewModel.rows.first { $0.isSelected }.isNil
            StandardButton(Loc.Set.Button.Title.apply, style: .primaryLarge) {
                viewModel.handleDate()
            }
            .disabled(disabled)
            .padding(.top, 20)
        }
    }
}
