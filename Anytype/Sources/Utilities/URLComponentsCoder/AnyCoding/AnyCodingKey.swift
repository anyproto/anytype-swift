import Foundation


struct AnyCodingKey: CodingKey, Equatable, Hashable {
    let stringValue: String
    let intValue: Int?
    
    init?(stringValue: String) {
        self.stringValue = stringValue
        self.intValue = nil
    }
    
    init?(intValue: Int) {
        self.stringValue = "\(intValue)"
        self.intValue = intValue
    }
    
    init<Key>(_ base: Key) where Key : CodingKey {
        if let intValue = base.intValue {
            self.init(intValue: intValue)!
        } else {
            self.init(stringValue: base.stringValue)!
        }
    }

    // MARK: - Hashable
    func hash(into hasher: inout Hasher) {
        if let intValue = self.intValue {
            hasher.combine(intValue)
        }
        else {
            hasher.combine(self.stringValue)
        }
    }
}

