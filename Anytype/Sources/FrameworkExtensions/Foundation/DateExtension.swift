import Foundation

extension Date {

    static var yesterday: Date {
         Calendar.current.date(byAdding: .day, value: -1, to: Date())!
    }
    
    static var tomorrow: Date {
         Calendar.current.date(byAdding: .day, value: 1, to: Date())!
    }
    
    init(milliseconds: Int64) {
        self = Date(timeIntervalSince1970: TimeInterval(milliseconds) / 1000)
    }
    
    func trimTime() -> Date? {
        let components = Calendar.current.dateComponents([.year, .month, .day], from: self)
        let date = Calendar.current.date(from: components)
        return date
    }
}

extension ClosedRange where Bound == Date {
    
    // MARK: - available date range for all platforms
    static let anytypeDateRange: ClosedRange<Date> = {
        let calendar = Calendar.current
        let startComponents = DateComponents(year: 0, month: 1, day: 1)
        let endComponents = DateComponents(year: 3000, month: 12, day: 31)
        
        guard let startDate = calendar.date(from: startComponents),
              let endDate = calendar.date(from: endComponents) else {
            return Date()...Date()
        }
        
        return startDate...endDate
    }()
}
