import Foundation

struct DateCalendarData: Identifiable {
    let date: Date
    let onDateChanged: (Date) -> Void
    
    var id: Date { date }
}
