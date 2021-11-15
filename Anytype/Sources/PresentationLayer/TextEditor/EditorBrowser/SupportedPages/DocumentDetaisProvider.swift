import BlocksModels

protocol DocumentDetaisProvider {
    var documentId: BlockId { get }
    var details: ObjectDetails? { get }
}

extension EditorPageController: DocumentDetaisProvider {
    var documentId: BlockId {
        viewModel.document.objectId
    }
    
    var details: ObjectDetails? {
        viewModel.document.objectDetails
    }
}

extension EditorSetHostingController: DocumentDetaisProvider {
    var details: ObjectDetails? {
        model.document.objectDetails
    }
}
