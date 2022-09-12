import Foundation

extension RelationValueProvider {
    
    func stringValue(for key: String) -> String {
        value(for: key)
    }

    func boolValue(for key: String) -> Bool {
        value(for: key)
    }
}
