import Foundation

struct ObjectHeaderEmptyData: Hashable {
    let onTap: () -> Void
}

extension ObjectHeaderEmptyData {
    
    func hash(into hasher: inout Hasher) {}
    
    static func == (lhs: ObjectHeaderEmptyData, rhs: ObjectHeaderEmptyData) -> Bool {
        return true
    }
    
}
