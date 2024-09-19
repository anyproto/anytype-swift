import Foundation

final class AnytypeRelativeDateTimeFormatter {
    
    private let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        return dateFormatter
    }()
    
    private let fallbackDateFormatter: RelativeDateTimeFormatter = {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .spellOut
        formatter.dateTimeStyle = .named
        formatter.formattingContext = .beginningOfSentence
        return formatter
    }()
    
    func localizedString(for date: Date, relativeTo referenceDate: Date) -> String {
        let date = dateFormatter.calendar.startOfDay(for: date)
        let referenceDate = dateFormatter.calendar.startOfDay(for: referenceDate)
        
        let interval = dateFormatter.calendar.dateComponents([.day], from: date, to: referenceDate)
        
        guard let days = interval.day else {
           return fallbackDateFormatter.localizedString(for: date, relativeTo: referenceDate)
        }
        
        switch days {
        case 0:
            return Loc.today
        case 1:
            return Loc.yesterday
        case 2...7:
            return Loc.RelativeFormatter.days7
        case 8...14:
            return Loc.RelativeFormatter.days14
        case 15...:
            if currentDate(date, isEqualToYears: referenceDate) {
                dateFormatter.setLocalizedDateFormatFromTemplate("MMMM")
            } else {
                dateFormatter.setLocalizedDateFormatFromTemplate("MMMM YYYY")
            }
            return dateFormatter.string(from: date)
        default:
            return fallbackDateFormatter.localizedString(for: date, relativeTo: referenceDate)
        }
    }
    
    private func currentDate(_ date1: Date, isEqualToYears date2: Date) -> Bool {
        dateFormatter.calendar.isDate(date1, equalTo: date2, toGranularity: .year)
    }
}
