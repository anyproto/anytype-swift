import Services
import AnytypeCore
import UIKit

// LECACY: Use EditorPageModuleOutput + EditorPageCoordinatorView instead
@MainActor
protocol EditorRouterProtocol:
    AnyObject,
    ObjectHeaderRouterProtocol
{
    func showAlert(alertModel: AlertModel)
    func showObject(objectId: String, forceOpenObject: Bool)
    func showObject(objectId: String)
    func showEditorScreen(data: ScreenData)
    func replaceCurrentPage(with data: EditorScreenData)
    
    func showBookmarkBar(completion: @escaping (AnytypeURL) -> ())
    func showLinkMarkup(url: AnytypeURL?, completion: @escaping (AnytypeURL?) -> Void)
    
    func showFilePicker(model: AnytypePicker.ViewModel)
    func showImagePicker(contentType: MediaPickerContentType, onSelect: @escaping (NSItemProvider?) -> Void)
    func showCamera(onMediaTaken: @escaping (ImagePickerMediaType) -> Void)
    
    func saveFile(fileURL: URL, type: FileContentType)
    
    func showStyleMenu(
        informations: [BlockInformation],
        restrictions: any BlockRestrictions,
        didShow: @escaping (UIView) -> Void,
        onDismiss: @escaping () -> Void
    )

    func showMarkupBottomSheet(
        selectedBlockIds: [String],
        viewDidClose: @escaping () -> Void
    )
    
    func showSettings()
    func showSettings(output: any ObjectSettingsCoordinatorOutput)
    func showTextIconPicker(contextId: String, objectId: String)
    
    func showMoveTo(onSelect: @escaping (ObjectDetails) -> ())
    func showLinkTo(onSelect: @escaping (ObjectDetails) -> ())

    func showTypes(selectedObjectId: String?, onSelect: @escaping (ObjectType) -> ())
    func showTypeSearchForObjectCreation(selectedObjectId: String?, onSelect: @escaping (TypeSelectionResult) -> ())
    func showObjectPreview(
        blockLinkState: BlockLinkState,
        onSelect: @escaping (BlockLink.Appearance) -> Void
    )
    
    func showRelationValueEditingView(key: String)
    func showAddPropertyInfoView(document: some BaseDocumentProtocol, onSelect: @escaping (PropertyDetails, _ isNew: Bool) -> Void)
    func showLinkContextualMenu(inputParameters: TextBlockURLInputParameters)

    func showWaitingView(text: String)
    func hideWaitingView()
    
    func presentSheet(_ vc: UIViewController)
    func presentFullscreen(_ vc: UIViewController)
    
    func showColorPicker(
        onColorSelection: @escaping (ColorView.ColorItem) -> Void,
        selectedColor: UIColor?,
        selectedBackgroundColor: UIColor?
    )
    
    @MainActor
    func showTemplatesPicker()
    
    func showDatePicker(onDateSelection: @escaping (Date) -> Void)
}
