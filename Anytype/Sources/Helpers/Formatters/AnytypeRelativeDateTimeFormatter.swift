import Foundation

final class AnytypeRelativeDateTimeFormatter {
    
    private let fallbackDateFormatter: RelativeDateTimeFormatter = {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .spellOut
        formatter.dateTimeStyle = .named
        formatter.formattingContext = .beginningOfSentence
        return formatter
    }()
    
    func localizedString(for date: Date, relativeTo referenceDate: Date) -> String {
        let date = fallbackDateFormatter.calendar.startOfDay(for: date)
        let referenceDate = fallbackDateFormatter.calendar.startOfDay(for: referenceDate)
        
        let interval = fallbackDateFormatter.calendar.dateComponents([.day], from: date, to: referenceDate)
        
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
        case 8...30:
            return Loc.RelativeFormatter.days30
        case 31...:
            return Loc.RelativeFormatter.older
        default:
            return fallbackDateFormatter.localizedString(for: date, relativeTo: referenceDate)
        }
    }
}
