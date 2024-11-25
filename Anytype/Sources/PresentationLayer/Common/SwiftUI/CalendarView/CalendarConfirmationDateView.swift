import SwiftUI

struct CalendarConfirmationDateView: View {
    
    @State var date: Date
    var onApply: (Date) -> Void
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            DragIndicator()
            calendarView
            Spacer()
            applyButton
        }
    }
    
    private var calendarView: some View {
        CalendarView(
            data: CalendarData(
                date: date,
                onDateChanged: { newDate in
                    date = newDate
                }
            )
        )
    }
    
    private var applyButton: some View {        
        StandardButton(Loc.apply, style: .primaryLarge) {
            onApply(date)
            dismiss()
        }
        .padding(.horizontal, 20)
    }
}

#Preview {
    CalendarConfirmationDateView(
        date: Date(),
        onApply: { _ in }
    )
}
