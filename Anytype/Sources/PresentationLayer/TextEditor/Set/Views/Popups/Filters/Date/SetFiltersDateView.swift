import SwiftUI

struct SetFiltersDateViewData {
    let filter: SetFilter
    let onApplyDate: (SetFiltersDate) -> Void
}

struct SetFiltersDateView: View {
    @StateObject private var viewModel: SetFiltersDateViewModel
    
    init(data: SetFiltersDateViewData, setSelectionModel: SetFiltersSelectionViewModel?) {
        _viewModel = StateObject(wrappedValue: SetFiltersDateViewModel(data: data, setSelectionModel: setSelectionModel))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer.fixedHeight(10)
            rows
            button
        }
        .padding(.horizontal, 20)
        .sheet(item: $viewModel.filtersDaysData) { data in
            SetTextView(data: data)
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
