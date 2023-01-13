import BlocksModels
import AnytypeCore
import UIKit

protocol AttachmentRouterProtocol {
    func openImage(_ imageContext: FilePreviewContext)
}
protocol ToastRouterProtocol {
    func showFailureToast(message: String)
}

protocol EditorRouterProtocol:
    AnyObject,
    EditorPageOpenRouterProtocol,
    AttachmentRouterProtocol,
    ObjectHeaderRouterProtocol,
    ToastRouterProtocol
{
    func showAlert(alertModel: AlertModel)
    func showPage(data: EditorScreenData)
    func replaceCurrentPage(with data: EditorScreenData)
    
    func openUrl(_ url: URL)
    func showBookmarkBar(completion: @escaping (AnytypeURL) -> ())
    func showLinkMarkup(url: AnytypeURL?, completion: @escaping (AnytypeURL?) -> Void)
    
    func showFilePicker(model: Picker.ViewModel)
    func showImagePicker(contentType: MediaPickerContentType, onSelect: @escaping (NSItemProvider?) -> Void)
    
    func saveFile(fileURL: URL, type: FileContentType)
    
    func showCodeLanguage(blockId: BlockId)
    
    func showStyleMenu(
        information: BlockInformation,
        restrictions: BlockRestrictions,
        didShow: @escaping (UIView) -> Void,
        onDismiss: @escaping () -> Void
    )

    func showMarkupBottomSheet(
        selectedBlockIds: [BlockId],
        viewDidClose: @escaping () -> Void
    )
    
    func showSettings()
    func showTextIconPicker(contextId: BlockId, objectId: BlockId)
    
    func showMoveTo(onSelect: @escaping (BlockId) -> ())
    func showLinkTo(onSelect: @escaping (ObjectDetails) -> ())
    func showSearch(onSelect: @escaping (EditorScreenData) -> ())

    func showTypes(selectedObjectId: BlockId?, onSelect: @escaping (BlockId) -> ())
    func showTypesForEmptyObject(selectedObjectId: BlockId?, onSelect: @escaping (BlockId) -> ())
    func showObjectPreview(
        blockLinkState: BlockLinkState,
        onSelect: @escaping (BlockLink.Appearance) -> Void
    )
    
    func showRelationValueEditingView(key: String)
    func showRelationValueEditingView(objectId: BlockId, relation: Relation)
    func showAddNewRelationView(onSelect: ((RelationDetails, _ isNew: Bool) -> Void)?)

    func showLinkContextualMenu(inputParameters: TextBlockURLInputParameters)

    func showWaitingView(text: String)
    func hideWaitingView()
    
    func closeEditor()
    
    func presentSheet(_ vc: UIViewController)
    func presentFullscreen(_ vc: UIViewController)
    
    func showTemplatesPopupIfNeeded(
        document: BaseDocumentProtocol,
        templatesTypeId: ObjectTypeId,
        onShow: (() -> Void)?
    )
    func showTemplatesPopupWithTypeCheckIfNeeded(
        document: BaseDocumentProtocol,
        templatesTypeId: ObjectTypeId,
        onShow: (() -> Void)?
    )
    
    func showColorPicker(
        onColorSelection: @escaping (ColorView.ColorItem) -> Void,
        selectedColor: UIColor?,
        selectedBackgroundColor: UIColor?
    )
}
