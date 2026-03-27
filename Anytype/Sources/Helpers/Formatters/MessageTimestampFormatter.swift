import Foundation

final class MessageTimestampFormatter {

    private let calendar = Calendar.current

    private let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter
    }()

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        return formatter
    }()

    func string(for date: Date) -> String {
        let now = Date()
        let startOfToday = calendar.startOfDay(for: now)
        let startOfDate = calendar.startOfDay(for: date)

        let dayDiff = calendar.dateComponents([.day], from: startOfDate, to: startOfToday).day ?? 0

        switch dayDiff {
        case 0:
            return timeFormatter.string(from: date)
        case 1:
            return Loc.yesterday
        default:
            if calendar.isDate(date, equalTo: now, toGranularity: .year) {
                dateFormatter.setLocalizedDateFormatFromTemplate("MMM d")
            } else {
                dateFormatter.setLocalizedDateFormatFromTemplate("MMM d, yyyy")
            }
            return dateFormatter.string(from: date)
        }
    }
}
