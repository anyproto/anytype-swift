import BlocksModels

protocol TextViewManagingFocus: AnyObject {
    func shouldResignFirstResponder()
    func setFocus(_ position: BlockFocusPosition)
    func obtainFocusPosition() -> BlockFocusPosition?
}
