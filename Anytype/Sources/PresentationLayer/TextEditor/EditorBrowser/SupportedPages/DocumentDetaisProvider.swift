import BlocksModels

protocol DocumentDetaisProvider {
    var objectId: BlockId { get }
    var details: ObjectDetails? { get }
}

extension EditorPageController: DocumentDetaisProvider {
    var objectId: BlockId {
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
