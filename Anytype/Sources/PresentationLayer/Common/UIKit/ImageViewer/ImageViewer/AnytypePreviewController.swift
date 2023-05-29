import QuickLook
import Combine
import BlocksModels
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

    init(
        with items: [PreviewRemoteItem],
        sourceView: UIView?,
        onContentChanged: @escaping (URL) -> Void
    ) {
        self.items = items
        self.sourceView = sourceView
        self.onContentChanged = onContentChanged

        super.init(nibName: nil, bundle: nil)

        self.currentPreviewItemIndex = 0

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

        items.forEach { item in
            item.didUpdateContentSubject.sinkWithResult { [weak self] _ in
                guard let self = self else { return }
                if self.didFinishTransition {
                    self.refreshCurrentPreviewItem()
                } else {
                    self.hasUpdates = true
                }

            }.store(in: &itemsSubscriptions)
        }
    }
}

extension AnytypePreviewController: QLPreviewControllerDataSource, QLPreviewControllerDelegate {
    // MARK: - QLPreviewControllerDataSource

    func previewController(_ controller: QLPreviewController, shouldOpen url: URL, for item: QLPreviewItem) -> Bool {
        return false
    }

    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return 1
    }

    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        items[index]
    }

    // MARK: - QLPreviewControllerDelegate

    func previewController(_ controller: QLPreviewController, editingModeFor previewItem: QLPreviewItem) -> QLPreviewItemEditingMode {
        .updateContents
    }

    func previewController(_ controller: QLPreviewController, didUpdateContentsOf previewItem: QLPreviewItem) {
        previewItem.previewItemURL.map(onContentChanged)
    }

    func previewController(_ controller: QLPreviewController, didSaveEditedCopyOf previewItem: QLPreviewItem, at modifiedContentsURL: URL) {
        onContentChanged(modifiedContentsURL)
    }

    func previewController(_ controller: QLPreviewController, transitionViewFor item: QLPreviewItem) -> UIView? {
        sourceView
    }
}
