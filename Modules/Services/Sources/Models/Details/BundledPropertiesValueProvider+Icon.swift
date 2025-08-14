import Foundation

public extension BundledPropertiesValueProvider {
    var objectIcon: ObjectIcon? {
        Container.shared.objectIconBuilder().objectIcon(relations: self)
    }
}
