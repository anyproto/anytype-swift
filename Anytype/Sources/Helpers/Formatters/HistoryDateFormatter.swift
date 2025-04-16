import Foundation

final class HistoryDateFormatter: Sendable {
    
    private let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        return dateFormatter
    }()
    
    func localizedDateString(for date: Date) -> String {
        let date = dateFormatter.calendar.startOfDay(for: date)
        let todayDate = dateFormatter.calendar.startOfDay(for: Date())
        
        let interval = dateFormatter.calendar.dateComponents([.day], from: date, to: todayDate)
        
        guard let days = interval.day else {
            return dateFormatter.string(from: date)
        }
        
        switch days {
        case 0:
            return Loc.today
        case 1:
            return Loc.yesterday
        default:
            if currentDate(date, isEqualToYears: todayDate) {
                dateFormatter.setLocalizedDateFormatFromTemplate("MMMM dd")
            } else {
                dateFormatter.setLocalizedDateFormatFromTemplate("MMMM dd YYYY")
            }
            return dateFormatter.string(from: date)
        }
    }
    
    func dateTimeString(for date: Date) -> String {
        if currentDate(date, isEqualToYears: Date()) {
            dateFormatter.setLocalizedDateFormatFromTemplate("MMMM dd HH:mm")
        } else {
            dateFormatter.setLocalizedDateFormatFromTemplate("MMMM dd YYYY HH:mm")
        }
        
        return dateFormatter.string(from: date)
    }
    
    func currentDate(_ date1: Date, isEqualToMinutes date2: Date) -> Bool {
        dateFormatter.calendar.isDate(date1, equalTo: date2, toGranularity: .minute)
    }
    
    private func currentDate(_ date1: Date, isEqualToYears date2: Date) -> Bool {
        dateFormatter.calendar.isDate(date1, equalTo: date2, toGranularity: .year)
    }
}
