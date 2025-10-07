import Foundation

final class ChatPreviewDateFormatter: Sendable {
    
    private let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        return dateFormatter
    }()
    
    func localizedDateString(for initialDate: Date, showTodayTime: Bool = false) -> String {
        let date = dateFormatter.calendar.startOfDay(for: initialDate)
        let todayDate = dateFormatter.calendar.startOfDay(for: Date())
        
        let interval = dateFormatter.calendar.dateComponents([.day], from: date, to: todayDate)
        
        guard let days = interval.day else {
            return dateFormatter.string(from: date)
        }
        
        switch days {
        case 0:
            if showTodayTime {
                dateFormatter.setLocalizedDateFormatFromTemplate("HH:mm")
                return dateFormatter.string(from: initialDate)
            } else {
                return Loc.today
            }
        case 1:
            return Loc.yesterday
        case 2...7:
            dateFormatter.setLocalizedDateFormatFromTemplate("EEE")
            return dateFormatter.string(from: initialDate)
        default:
            if currentDate(initialDate, isEqualToYears: Date()) {
                dateFormatter.setLocalizedDateFormatFromTemplate("MM/dd")
                return dateFormatter.string(from: initialDate)
            } else {
                dateFormatter.setLocalizedDateFormatFromTemplate("MM/dd/yy")
                return dateFormatter.string(from: initialDate)
            }
        }
    }
    
    private func currentDate(_ date1: Date, isEqualToYears date2: Date) -> Bool {
        dateFormatter.calendar.isDate(date1, equalTo: date2, toGranularity: .year)
    }
}