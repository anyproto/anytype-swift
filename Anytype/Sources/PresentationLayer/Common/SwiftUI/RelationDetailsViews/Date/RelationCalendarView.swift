import SwiftUI
import Services

struct RelationCalendarView: View {
    
    @StateObject var viewModel: RelationCalendarViewModel
    @Environment(\.dismiss) var dismiss
    
    init(date: Date?, configuration: RelationModuleConfiguration, output: (any RelationCalendarOutput)?) {
        _viewModel = StateObject(wrappedValue: RelationCalendarViewModel(
            date: date,
            configuration: configuration,
            output: output
        ))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            DragIndicator()
            navigationBar
            calendarView
            openCurrentDateView
        }
        .onChange(of: viewModel.dismiss) { _ in
            dismiss()
        }
    }
    
    private var calendarView: some View {
        CalendarView(
            data: CalendarData(
                date: viewModel.date,
                onDateChanged: { newDate in
                    viewModel.dateChanged(newDate)
                }
            )
        )
        .newDivider(leadingPadding: 16)
    }
    
    private var openCurrentDateView: some View {
        Button {
            viewModel.onOpenCurrentDateSelected()
        } label: {
            HStack(spacing: 0) {
                AnytypeText(Loc.Date.Open.Action.title, style: .bodyRegular)
                    .foregroundColor(.Text.primary)
                Spacer()
                Image(asset: .X24.Arrow.right)
                    .foregroundColor(.Control.active)
            }
        }
        .frame(height: 44)
        .frame(maxWidth: .infinity, alignment: .leading)
        .fixTappableArea()
        .padding(.horizontal, 16)
        .newDivider(leadingPadding: 16)
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
    RelationCalendarView(
        date: nil,
        configuration: RelationModuleConfiguration.default,
        output: nil
    )
}
