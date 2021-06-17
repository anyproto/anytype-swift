import Foundation

struct CodingPathConverter {
    let codingKey: CodingKey
    init(_ codingKey: CodingKey) {
        self.codingKey = codingKey
    }
    var stringValue: String {
        self.codingKey.intValue.flatMap({$0.description}) ?? self.codingKey.stringValue
    }
}
