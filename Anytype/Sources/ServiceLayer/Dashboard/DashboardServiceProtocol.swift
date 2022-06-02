import AnytypeCore
import BlocksModels

protocol DashboardServiceProtocol {
    
    func createNewPage(isDraft: Bool, templateId: BlockId?) -> BlockId?
}
