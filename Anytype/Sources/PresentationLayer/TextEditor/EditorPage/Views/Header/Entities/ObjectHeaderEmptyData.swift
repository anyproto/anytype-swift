import Foundation

struct ObjectHeaderEmptyData: Hashable {
    enum ObjectHeaderEmptyUsecase: Codable {
        case editor
        case templateEditing
    }
    
    let presentationStyle: ObjectHeaderEmptyUsecase
    @EquatableNoop private(set) var onTap: () -> Void
}
