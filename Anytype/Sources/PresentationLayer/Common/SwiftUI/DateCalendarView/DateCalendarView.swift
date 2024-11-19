import SwiftUI

struct DateCalendarView: View {
    
    // mostly for UIKit presentation
    let height: CGFloat = 475
    
    @State var date: Date
    var embedded: Bool = false
    var onDateChanged: (Date) -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            if !embedded {
                DragIndicator()
            }
            list
        }
        .background(Color.Background.secondary)
        .frame(height: height)
        .onChange(of: date) { newDate in
            onDateChanged(newDate)
        }
    }
    
    private var list: some View {
        PlainList {
            calendar
            quickOptions
        }
        .buttonStyle(BorderlessButtonStyle())
        .bounceBehaviorBasedOnSize()
    }
    
    private var calendar: some View {
        DatePicker("", selection: $date, in: ClosedRange.anytypeDateRange, displayedComponents: .date)
            .datePickerStyle(.graphical)
            .accentColor(Color.System.amber125)
            .padding(.horizontal, 16)
            .newDivider(leadingPadding: 16)
    }
    
    private var quickOptions: some View {
        ForEach(DateRelationCalendarQuickOption.allCases) { option in
            quickOptionRow(option)
                .padding(.horizontal, 16)
                .if(!option.isLast, transform: {
                    $0.newDivider(leadingPadding: 16)
                })
        }
    }
    
    private func quickOptionRow(_ option: DateRelationCalendarQuickOption) -> some View {
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
    DateCalendarView(
        date: Date(),
        onDateChanged: { _ in }
    )
}
