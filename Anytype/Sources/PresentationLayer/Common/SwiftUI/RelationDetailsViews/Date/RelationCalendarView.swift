import SwiftUI
import Services

struct RelationCalendarView: View {
    
    @StateObject var viewModel: RelationCalendarViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var clearButtonWidth: CGFloat = .zero
    
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
        .background(Color.Background.secondary)
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
                Image(asset: .RightAttribute.disclosure)
            }
        }
        .frame(height: 44)
        .frame(maxWidth: .infinity, alignment: .leading)
        .fixTappableArea()
        .padding(.horizontal, 16)
        .newDivider(leadingPadding: 16)
    }
    
    private var navigationBar: some View {
        HStack(spacing: 6) {
            clearButton
            AnytypeText(viewModel.config.title, style: .uxTitle1Semibold)
                .foregroundColor(.Text.primary)
                .lineLimit(1)
                .frame(maxWidth: .infinity)
            Spacer.fixedWidth(clearButtonWidth)
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
        .readSize { size in
            clearButtonWidth = size.width
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
