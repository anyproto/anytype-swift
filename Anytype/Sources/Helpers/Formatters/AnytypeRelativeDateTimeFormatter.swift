import Foundation

final class AnytypeRelativeDateTimeFormatter {
    
    private let dateFormatter: RelativeDateTimeFormatter = {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .spellOut
        formatter.dateTimeStyle = .named
        formatter.formattingContext = .beginningOfSentence
        return formatter
    }()
    
    func localizedString(for date: Date, relativeTo referenceDate: Date) -> String {
        let interval = dateFormatter.calendar.dateComponents([.day], from: date, to: referenceDate)
        
        if abs(interval.day ?? 0) > 0 {
            return dateFormatter.localizedString(for: date, relativeTo: referenceDate)
        } else {
            return Loc.today
        }
    }
}
