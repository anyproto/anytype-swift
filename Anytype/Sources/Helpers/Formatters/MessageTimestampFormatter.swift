import Foundation

final class MessageTimestampFormatter: Sendable {

    private let calendar = Calendar.current

    func string(for date: Date) -> String {
        let now = Date()
        let startOfToday = calendar.startOfDay(for: now)
        let startOfDate = calendar.startOfDay(for: date)

        let dayDiff = calendar.dateComponents([.day], from: startOfDate, to: startOfToday).day ?? 0

        switch dayDiff {
        case 0:
            let formatter = DateFormatter()
            formatter.dateStyle = .none
            formatter.timeStyle = .short
            return formatter.string(from: date)
        case 1:
            return Loc.yesterday
        default:
            let formatter = DateFormatter()
            if calendar.isDate(date, equalTo: now, toGranularity: .year) {
                formatter.setLocalizedDateFormatFromTemplate("MMM d")
            } else {
                formatter.setLocalizedDateFormatFromTemplate("MMM d, yyyy")
            }
            return formatter.string(from: date)
        }
    }
}
