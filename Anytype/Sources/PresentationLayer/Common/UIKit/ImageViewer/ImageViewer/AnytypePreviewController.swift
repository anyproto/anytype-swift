import QuickLook
import Combine
import Services
import AnytypeCore

final class AnytypePreviewController: QLPreviewController {
    var didFinishTransition = false {
        didSet {
            if hasUpdates && didFinishTransition {
                refreshCurrentPreviewItem()
                hasUpdates = false
            }
        }
    }

    var hasUpdates = false

    private let items: [PreviewRemoteItem]
    private let onContentChanged: (URL) -> Void
    private var itemsSubscriptions = [AnyCancellable]()
    private weak var sourceView: UIView?
    private let initialPreviewItemIndex: Int

    init(
        with items: [PreviewRemoteItem],
        initialPreviewItemIndex: Int = 0,
        sourceView: UIView? = nil,
        onContentChanged: @escaping (URL) -> Void = { _ in }
    ) {
        self.items = items
        self.sourceView = sourceView
        self.onContentChanged = onContentChanged
        self.initialPreviewItemIndex = initialPreviewItemIndex

        super.init(nibName: nil, bundle: nil)

        navigationItem.leftBarButtonItem = nil
        navigationController?.navigationItem.leftBarButtonItem = nil
    }


    required init?(coder: NSCoder) {
        fatalError("Not implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        delegate = self
        dataSource = self
        currentPreviewItemIndex = initialPreviewItemIndex

        items.forEach { item in
            item.didUpdateContentSubject.receiveOnMain().sinkWithResult { [weak self] _ in
                self?.handleItemUpdate()
            }.store(in: &itemsSubscriptions)
        }
    }
    
    private func handleItemUpdate() {
        if FeatureFlags.doNotWaitCompletionInAnytypePreview {
            refreshCurrentPreviewItem()
            return
        }
        
        if didFinishTransition {
            refreshCurrentPreviewItem()
        } else {
            hasUpdates = true
        }
    }
}

extension AnytypePreviewController: QLPreviewControllerDataSource, QLPreviewControllerDelegate {
    // MARK: - QLPreviewControllerDataSource

    func previewController(_ controller: QLPreviewController, shouldOpen url: URL, for item: any QLPreviewItem) -> Bool {
        return false
    }

    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return items.count
    }

    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> any QLPreviewItem {
        items[index]
    }

    // MARK: - QLPreviewControllerDelegate

    func previewController(_ controller: QLPreviewController, editingModeFor previewItem: any QLPreviewItem) -> QLPreviewItemEditingMode {
        .disabled
    }

    func previewController(_ controller: QLPreviewController, didUpdateContentsOf previewItem: any QLPreviewItem) {
        previewItem.previewItemURL.map(onContentChanged)
    }

    func previewController(_ controller: QLPreviewController, didSaveEditedCopyOf previewItem: any QLPreviewItem, at modifiedContentsURL: URL) {
        onContentChanged(modifiedContentsURL)
    }

    func previewController(_ controller: QLPreviewController, transitionViewFor item: any QLPreviewItem) -> UIView? {
        sourceView
    }
}
