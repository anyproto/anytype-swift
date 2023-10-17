import Foundation

public protocol DetailsModel {
    init(details: ObjectDetails)
    static var subscriptionKeys: [BundledRelationKey] { get }
}
