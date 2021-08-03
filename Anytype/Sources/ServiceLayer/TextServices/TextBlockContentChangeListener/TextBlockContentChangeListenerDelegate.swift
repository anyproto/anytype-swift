import BlocksModels

/// Entity which will be notified after middleware will send event
protocol TextBlockContentChangeListenerDelegate: AnyObject {
    
    func blockInformationDidChange(_ information: BlockInformation)
    func blockHasBeenDeleted()
}
