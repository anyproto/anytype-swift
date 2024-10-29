import SwiftUI
import Services

struct DateRelationCalendarView: View {
    
    @StateObject var viewModel: DateRelationCalendarViewModel
    @Environment(\.dismiss) var dismiss
    
    init(date: Date?, configuration: RelationModuleConfiguration) {
        _viewModel = StateObject(wrappedValue: DateRelationCalendarViewModel(
            date: date,
            configuration: configuration
        ))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            DragIndicator()
            navigationBar
            dateCalendarView
        }
        .fitPresentationDetents()
    }
    
    private var dateCalendarView: some View {
        DateCalendarView(
            date: viewModel.date,
            embedded: true,
            onDateChanged: { newDate in
                viewModel.dateChanged(newDate)
            }
        )
        .onChange(of: viewModel.dismiss) { _ in
            dismiss()
        }
    }
    
    private var navigationBar: some View {
        HStack(alignment: .center, spacing: 0) {
            Spacer()
            AnytypeText(viewModel.config.title, style: .uxTitle1Semibold)
                .foregroundColor(.Text.primary)
            Spacer()
        }
        .overlay(alignment: .leading) {
            clearButton
        }
        .frame(height: 48)
        .padding(.horizontal, 16)
    }
    
    private var clearButton: some View {
        Button {
            viewModel.clear()
        } label: {
            AnytypeText(Loc.clear, style: .uxBodyRegular)
                .foregroundColor(.Control.active)
        }
    }
}

#Preview {
    DateRelationCalendarView(
        date: nil,
        configuration: RelationModuleConfiguration.default
    )
}
