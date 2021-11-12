import Foundation

extension String {
    func isRangeValid(_ range: NSRange) -> Bool {
        count > 0 && count >= range.length + range.location && range.location >= 0
    }
}
