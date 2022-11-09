import BlocksModels

protocol DetailsServiceProtocol {
        
    func updateBundledDetails(_ bundledDpdates: [BundledDetails])
    func updateBundledDetails(contextID: String, bundledDpdates: [BundledDetails])
    func setLayout(_ detailsLayout: DetailsLayout)
    func updateDetails(contextId: String, relationKey: String, value: DataviewGroupValue)
}
