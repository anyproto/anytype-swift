import BlocksModels
import AnytypeCore
import UIKit

protocol AttachmentRouterProtocol {
    func openImage(_ imageContext: BlockImageViewModel.ImageOpeningContext)
}

protocol EditorRouterProtocol: AnyObject, AttachmentRouterProtocol {
    func showAlert(alertModel: AlertModel)

    func showPage(data: EditorScreenData)
    func openUrl(_ url: URL)
    func showBookmarkBar(completion: @escaping (URL) -> ())
    func showLinkMarkup(url: URL?, completion: @escaping (URL?) -> Void)
    
    func showFilePicker(model: Picker.ViewModel)
    func showImagePicker(contentType: MediaPickerContentType, onSelect: @escaping (NSItemProvider?) -> Void)
    
    func saveFile(fileURL: URL, type: FileContentType)
    
    func showCodeLanguageView(languages: [CodeLanguage], completion: @escaping (CodeLanguage) -> Void)
    
    func showStyleMenu(information: BlockInformation)
    
    func showSettings()
    func showCoverPicker()
    func showIconPicker()
    func showLayoutPicker()
    func showTextIconPicker(contextId: BlockId, objectId: BlockId)
    func presentUndoRedo()
    
    func showMoveTo(onSelect: @escaping (BlockId) -> ())
    func showLinkTo(onSelect: @escaping (BlockId) -> ())
    func showLinkToObject(onSelect: @escaping (LinkToObjectSearchViewModel.SearchKind) -> ())
    func showSearch(onSelect: @escaping (EditorScreenData) -> ())
    func showTypesSearch(onSelect: @escaping (BlockId) -> ())
    func showObjectPreview(blockLinkAppearance: BlockLink.Appearance, onSelect: @escaping (BlockLink.Appearance) -> Void)
    
    func showRelationValueEditingView(key: String, source: RelationSource)
    func showRelationValueEditingView(objectId: BlockId, source: RelationSource, relation: Relation)
    func showAddNewRelationView(onSelect: ((RelationMetadata, _ isNew: Bool) -> Void)?)

    func showLinkContextualMenu(inputParameters: TextBlockURLInputParameters)

    func showWaitingView(text: String)
    func hideWaitingView()
    
    func goBack()
    
    func presentSheet(_ vc: UIViewController)
    func presentFullscreen(_ vc: UIViewController)
    func setNavigationViewHidden(_ isHidden: Bool, animated: Bool)
    func showTemplatesAvailabilityPopupIfNeeded(
        document: BaseDocumentProtocol,
        templatesTypeURL: ObjectTypeUrl
    )

    func showCreateObject(pageId: BlockId)
    func showCreateBookmarkObject()
    
    func showSetSettings(setModel: EditorSetViewModel)
    func showSorts(setModel: EditorSetViewModel, dataviewService: DataviewServiceProtocol)
    func showRelationSearch(relations: [RelationMetadata], onSelect: @escaping (String) -> Void)
    
    func showFilters(setModel: EditorSetViewModel, dataviewService: DataviewServiceProtocol)
    func showColorPicker(
        onColorSelection: @escaping (ColorView.ColorItem) -> Void,
        selectedColor: UIColor?,
        selectedBackgroundColor: UIColor?
    )
}
