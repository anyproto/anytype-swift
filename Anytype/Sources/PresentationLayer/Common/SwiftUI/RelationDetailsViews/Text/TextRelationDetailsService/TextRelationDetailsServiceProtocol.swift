import Foundation

protocol TextRelationDetailsServiceProtocol: AnyObject {

    func saveRelation(value: String, key: String, textType: TextRelationDetailsViewType)
    
}
