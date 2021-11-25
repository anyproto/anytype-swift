import Foundation

protocol TextRelationEditingServiceProtocol {
    
    var valueType: TextRelationValueType { get }
    
    func save(value: String, forKey key: String)
    
}
