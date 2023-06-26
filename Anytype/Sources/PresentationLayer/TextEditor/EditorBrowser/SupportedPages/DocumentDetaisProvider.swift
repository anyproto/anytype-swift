import Services
import AnytypeCore

protocol DocumentDetaisProvider {
    
    var screenData: EditorScreenData { get }
    var documentTitle: String? { get }
    var documentDescription: String? { get }
}

extension EditorPageController: DocumentDetaisProvider {
    
    var screenData: EditorScreenData {
        .page(EditorPageObject(objectId: viewModel.document.objectId, isSupportedForEdit: true, isOpenedForPreview: false))
    }
    
    var documentTitle: String? {
        viewModel.document.details?.title
    }
    
    var documentDescription: String? {
        viewModel?.document.details?.description
    }
}

extension EditorSetHostingController: DocumentDetaisProvider {
    
    var screenData: EditorScreenData {
        .set(EditorSetObject(objectId: objectId, inline: nil, isSupportedForEdit: true))
    }
    
    var documentTitle: String? {
        model.details?.title
    }
    
    var documentDescription: String? {
        model.details?.description
    }
}
