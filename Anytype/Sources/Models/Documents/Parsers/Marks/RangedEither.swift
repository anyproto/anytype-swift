
enum RangedEither<Left, Right> {
    case range(Left)
    case whole(Right)
}
