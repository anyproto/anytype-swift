import Foundation

// For show modules with one String arg
struct StringIdentifiable: Identifiable {
    
    let value: String
    
    init(value: String) {
        self.value = value
    }
    
    var id: String { value }
}

extension String {
    var identifiable: StringIdentifiable {
        StringIdentifiable(value: self)
    }
}
