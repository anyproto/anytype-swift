extension BlockPageLinkViewModel {
    var targetBlockId: String {
        guard case let .link(link) = self.getBlock().blockModel.information.content else {
            assertionFailure("No target id for \(self)")
            return ""
        }
        
        return link.targetBlockID
    }
}
