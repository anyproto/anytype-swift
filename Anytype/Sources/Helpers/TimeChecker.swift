import QuartzCore

/// Entity which helps to make a debounce in case your don't use Combine
final class TimeChecker {
    /// Minimum time interval to stay idle to handle consequent return key presses
    private static let thresholdDelayBetweenConsequentReturnKeyPressing: CFTimeInterval = 0.5
    
    private var previous: CFTimeInterval?
    private let threshold: CFTimeInterval
    
    /// Initializator
    ///
    /// - Parameters:
    ///   - threshold: Time interval which will be checked during exceedsTimeInterval method calls
    init(threshold: CFTimeInterval = thresholdDelayBetweenConsequentReturnKeyPressing) {
        self.threshold = threshold
    }
    
    /// Returns true in case of time interval (threshold) has beed exceeded from last time calling this method, otherwise return false
    var exceedsTimeInterval: Bool {
        if let previous = self.previous, CACurrentMediaTime() - previous < self.threshold {
            return false
        }
        else {
            self.previous = CACurrentMediaTime()
            return true
        }
    }
}
