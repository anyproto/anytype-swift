import BlocksModels
import UIKit

protocol AttachmentRouterProtocol {
    func openImage(_ imageContext: BlockImageViewModel.ImageOpeningContext)
}

protocol EditorRouterProtocol: AnyObject, AttachmentRouterProtocol {
    
    func showPage(data: EditorScreenData)
    func openUrl(_ url: URL)
    func showBookmarkBar(completion: @escaping (URL) -> ())
    func showLinkMarkup(url: URL?, completion: @escaping (URL?) -> Void)
    
    func showFilePicker(model: Picker.ViewModel)
    func showImagePicker(model: MediaPickerViewModel)
    
    func saveFile(fileURL: URL, type: FileContentType)
    
    func showCodeLanguageView(languages: [CodeLanguage], completion: @escaping (CodeLanguage) -> Void)
    
    func showStyleMenu(information: BlockInformation)
    
    func showSettings()
    func showCoverPicker()
    func showIconPicker()
    func showLayoutPicker()
    
    func showMoveTo(onSelect: @escaping (BlockId) -> ())
    func showLinkTo(onSelect: @escaping (BlockId) -> ())
    func showLinkToObject(onSelect: @escaping (LinkToObjectSearchViewModel.SearchKind) -> ())
    func showSearch(onSelect: @escaping (EditorScreenData) -> ())
    func showTypesSearch(onSelect: @escaping (BlockId) -> ())
    func showObjectPreview(information: BlockInformation, onSelect: @escaping (ObjectPreviewFields) -> Void)
    
    func showRelationValueEditingView(key: String, source: RelationSource)
    func showRelationValueEditingView(objectId: BlockId, source: RelationSource, relation: Relation)
    func showAddNewRelationView(onSelect: ((RelationMetadata) -> Void)?)

    func showLinkContextualMenu(inputParameters: TextBlockURLInputParameters)

    func showWaitingView(_ shouldShow: Bool, text: String)
    
    func goBack()
    
    func presentFullscreen(_ vc: UIViewController)
    func setNavigationViewHidden(_ isHidden: Bool, animated: Bool)
}
