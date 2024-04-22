import Foundation

protocol ObjectIconActionHandlerProtocol: AnyObject {
    func handleIconAction(document: BaseDocumentGeneralProtocol, action: ObjectIconPickerAction)
}
