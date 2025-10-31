import SwiftUI

struct CalendarData: Identifiable {
    let date: Date
    let onDateChanged: (Date) -> Void
    
    var id: Date { date }
}

struct CalendarView: View {
    
    init(data: CalendarData) {
        self.date = data.date
        self.onDateChanged = data.onDateChanged
    }
    
    @State private var date: Date
    private var onDateChanged: (Date) -> Void
    
    @State private var height: CGFloat = .zero
    
    var body: some View {
        content
            .background(Color.Background.secondary)
            .onChange(of: date) { _, newDate in
                onDateChanged(newDate)
            }
            .frame(height: height)
    }
    
    private var content: some View {
        ScrollView {
            VStack(spacing: 0) {
                calendar
                quickOptions
            }
            .readSize { height = $0.height }
        }
        .scrollBounceBehavior(.basedOnSize)
    }
    
    private var calendar: some View {
        DatePicker("", selection: $date, in: ClosedRange.anytypeDateRange, displayedComponents: .date)
            .datePickerStyle(.graphical)
            .accentColor(Color.Control.accent125)
            .padding(.horizontal, 16)
            .newDivider(leadingPadding: 16)
    }
    
    private var quickOptions: some View {
        ForEach(PropertyCalendarQuickOption.allCases) { option in
            quickOptionRow(option)
                .padding(.horizontal, 16)
                .if(!option.isLast, transform: {
                    $0.newDivider(leadingPadding: 16)
                })
        }
    }
    
    private func quickOptionRow(_ option: PropertyCalendarQuickOption) -> some View {
        Button {
            date = option.date
        } label: {
            AnytypeText(option.title, style: .bodyRegular)
                .foregroundColor(.Text.primary)
                .frame(height: 44)
                .frame(maxWidth: .infinity, alignment: .leading)
                .fixTappableArea()
        }
    }
}

#Preview {
    CalendarView(
        data: CalendarData(
            date: Date(),
            onDateChanged: { _ in }
        )
    )
}
