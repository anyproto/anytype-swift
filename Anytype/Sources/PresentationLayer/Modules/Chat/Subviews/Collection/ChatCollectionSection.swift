import Foundation

protocol ChatCollectionSection {
    associatedtype Item
    
    var items: [Item] { get }
}
