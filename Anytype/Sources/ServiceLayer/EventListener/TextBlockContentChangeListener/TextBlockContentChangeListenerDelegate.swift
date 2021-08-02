import BlocksModels

protocol TextBlockContentChangeListenerDelegate: AnyObject {
    func blockInformationDidChange(_ information: BlockInformation)
}
