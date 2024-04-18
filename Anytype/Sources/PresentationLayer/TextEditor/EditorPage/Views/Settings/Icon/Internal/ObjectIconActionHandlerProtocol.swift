import Foundation

protocol ObjectIconActionHandlerProtocol: AnyObject {
    func handleIconAction(objectId: String, spaceId: String, action: ObjectIconPickerAction)
}
