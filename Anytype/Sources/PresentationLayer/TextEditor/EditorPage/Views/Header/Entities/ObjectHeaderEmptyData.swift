import Foundation

enum ObjectHeaderEmptyUsecase: Codable {
    case full
    case embedded
}

struct ObjectHeaderEmptyData: Hashable {
    let presentationStyle: ObjectHeaderEmptyUsecase
    @EquatableNoop private(set) var onTap: () -> Void
}
