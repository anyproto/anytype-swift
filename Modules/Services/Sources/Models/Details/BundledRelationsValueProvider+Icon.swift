import Foundation

public extension BundledRelationsValueProvider {
    var objectIcon: ObjectIcon {
        Container.shared.objectIconBuilder().objectIcon(relations: self)
    }
}
