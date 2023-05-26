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
}
