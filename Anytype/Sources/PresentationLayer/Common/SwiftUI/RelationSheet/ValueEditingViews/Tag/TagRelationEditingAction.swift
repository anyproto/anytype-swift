import Foundation

enum TagRelationEditingAction {
    case remove(IndexSet)
    case move(IndexSet, Int)
}
