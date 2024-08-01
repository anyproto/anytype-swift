import Foundation

final class VersionHistoryDateFormatter {
    
    private let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        return dateFormatter
    }()
    
    func localizedString(for date: Date) -> String {
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
            return dateFormatter.string(from: date)
        }
    }
}
