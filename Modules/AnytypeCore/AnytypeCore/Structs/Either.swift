import Foundation

public enum Either<L, R> {
    case left(L)
    case right(R)
    
    public static func from(left: L?, right: R?) -> Either<L, R>? {
        
        if let left {
            return Either.left(left)
        }
        
        if let right {
            return Either.right(right)
        }
        
        return nil
    }
}
