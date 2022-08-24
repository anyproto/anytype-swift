import Foundation

public enum Either<L, R> {
    case left(L)
    case right(R)
}
