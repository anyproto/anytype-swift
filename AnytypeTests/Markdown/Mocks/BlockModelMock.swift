import BlocksModels

final class BlockModelMock: BlockModelProtocol {
    var information: BlockInformation
    
    init(information: BlockInformation) {
        self.information = information
    }
    
    var parent: BlockModelProtocol?
    
    var kind: BlockKind = .block
    
    var indentationLevel: Int = 0
    
    var isFirstResponder = false
    
    var isToggled = false
    
    var focusAt: BlockFocusPosition?
    
    func toggle() {
        assertionFailure()
    }
    
    func unsetFirstResponder() {
        assertionFailure()
    }
}
