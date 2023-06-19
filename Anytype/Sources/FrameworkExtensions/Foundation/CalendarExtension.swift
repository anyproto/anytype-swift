import Foundation
import AnytypeCore

extension Calendar {
    func numberOfDaysBetween(_ from: Date, and to: Date) -> Int {
        let fromDate = startOfDay(for: from)
        let toDate = startOfDay(for: to)
        let numberOfDays = dateComponents([.day], from: fromDate, to: toDate)
        
        guard let days = numberOfDays.day else {
            anytypeAssertionFailure("No days", info: ["numberOfDays": "\(numberOfDays)"])
            return 0
        }
        
        return days
    }
}
