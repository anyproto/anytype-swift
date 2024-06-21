
public struct GradientId: Hashable, Sendable {
    
    private static let range = 1..<17
    
    public let rawValue: Int
    
    public init?(_ value: Int) {
        guard GradientId.range.contains(value) else {
            return nil
        }
        self.rawValue = value
    }
    
    private init(unsafeValue: Int) {
        self.rawValue = unsafeValue
    }
    
    public static var random: GradientId {
        GradientId(unsafeValue: Int.random(in: GradientId.range))
    }
}
