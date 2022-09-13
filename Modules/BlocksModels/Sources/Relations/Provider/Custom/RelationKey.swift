import Foundation

// Custom relation keys
public enum RelationKey: String {
    case title
    case readonlyValue
}

#warning("Drop when add readonlyValue relation in relations.json")
extension BundledRelationsValueProvider where Self: RelationValueProvider {
    
    var readonlyValue: Bool {
        value(for: RelationKey.readonlyValue.rawValue)
    }
}
