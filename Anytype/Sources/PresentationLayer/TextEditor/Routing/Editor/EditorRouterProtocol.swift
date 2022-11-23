import BlocksModels
import AnytypeCore
import UIKit

protocol AttachmentRouterProtocol {
    func openImage(_ imageContext: FilePreviewContext)
}

protocol EditorRouterProtocol: AnyObject, AttachmentRouterProtocol {
    func showAlert(alertModel: AlertModel)

    func showPage(data: EditorScreenData)
    func replaceCurrentPage(with data: EditorScreenData)
    
    func openUrl(_ url: URL)
    func showBookmarkBar(completion: @escaping (AnytypeURL) -> ())
    func showLinkMarkup(url: AnytypeURL?, completion: @escaping (AnytypeURL?) -> Void)
    
    func showFilePicker(model: Picker.ViewModel)
    func showImagePicker(contentType: MediaPickerContentType, onSelect: @escaping (NSItemProvider?) -> Void)
    
    func saveFile(fileURL: URL, type: FileContentType)
    
    func showCodeLanguageView(languages: [CodeLanguage], completion: @escaping (CodeLanguage) -> Void)
    
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
    func showCoverPicker()
    func showIconPicker()
    func showLayoutPicker()
    func showTextIconPicker(contextId: BlockId, objectId: BlockId)
    
    func showMoveTo(onSelect: @escaping (BlockId) -> ())
    func showLinkTo(onSelect: @escaping (BlockId, _ typeUrl: String) -> ())
    func showSearch(onSelect: @escaping (EditorScreenData) -> ())

    func showTypes(selectedObjectId: BlockId?, onSelect: @escaping (BlockId) -> ())
    func showTypesForEmptyObject(selectedObjectId: BlockId?, onSelect: @escaping (BlockId) -> ())
    func showSources(selectedObjectId: BlockId?, onSelect: @escaping (BlockId) -> ())
    func showObjectPreview(
        blockLinkState: BlockLinkState,
        onSelect: @escaping (BlockLink.Appearance) -> Void
    )
    
    func showRelationValueEditingView(key: String, source: RelationSource)
    func showRelationValueEditingView(objectId: BlockId, source: RelationSource, relation: Relation)
    func showAddNewRelationView(onSelect: ((RelationDetails, _ isNew: Bool) -> Void)?)

    func showLinkContextualMenu(inputParameters: TextBlockURLInputParameters)

    func showWaitingView(text: String)
    func hideWaitingView()
    
    func goBack()
    
    func presentSheet(_ vc: UIViewController)
    func presentFullscreen(_ vc: UIViewController)
    func setNavigationViewHidden(_ isHidden: Bool, animated: Bool)
    func showTemplatesAvailabilityPopupIfNeeded(
        document: BaseDocumentProtocol,
        templatesTypeId: ObjectTypeId
    )
    
    func showViewPicker(
        setModel: EditorSetViewModel,
        dataviewService: DataviewServiceProtocol,
        showViewTypes: @escaping RoutingAction<DataviewView?>
    )

    func showCreateObject(pageId: BlockId)
    func showCreateBookmarkObject()
    
    func showSetSettings(setModel: EditorSetViewModel)
    func showViewTypes(
        dataView: BlockDataview,
        activeView: DataviewView?,
        dataviewService: DataviewServiceProtocol
    )
    func showViewSettings(setModel: EditorSetViewModel, dataviewService: DataviewServiceProtocol)
    func dismissSetSettingsIfNeeded()
    func showSorts(setModel: EditorSetViewModel, dataviewService: DataviewServiceProtocol)
    func showRelationSearch(relationsDetails: [RelationDetails], onSelect: @escaping (RelationDetails) -> Void)
    func showFilterSearch(filter: SetFilter, onApply: @escaping (SetFilter) -> Void)
    
    func showFilters(setModel: EditorSetViewModel, dataviewService: DataviewServiceProtocol)
    func showColorPicker(
        onColorSelection: @escaping (ColorView.ColorItem) -> Void,
        selectedColor: UIColor?,
        selectedBackgroundColor: UIColor?
    )
    
    func showCardSizes(size: DataviewViewSize, onSelect: @escaping (DataviewViewSize) -> Void)
    func showCovers(setModel: EditorSetViewModel, onSelect: @escaping (String) -> Void)
    
    func showRelations()

    func showGroupByRelations(
        selectedRelationId: String,
        relations: [RelationDetails],
        onSelect: @escaping (String) -> Void
    )
}
