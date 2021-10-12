import UIKit
import BlocksModels

final class EditorSyncStatusItem: UIView {
    private lazy var item = EditorBarButtonItem(style: itemStyle)
    private var status: SyncStatus
    
    func changeBackgroundAlpha(_ alpha: CGFloat) {
        item.changeBackgroundAlpha(alpha)
    }
    
    func changeStatus(_ status: SyncStatus) {
        self.status = status
        item.changeStyle(style: itemStyle)
    }
    
    init(status: SyncStatus) {
        self.status = status
        super.init(frame: .zero)
        setup()
    }
    
    private func setup() {
        addSubview(item) {
            $0.pinToSuperview()
        }
    }
    
    private var itemStyle: EditorBarButtonItem.Style {
        .syncStatus(
            image: image,
            title: status.title,
            description: status.description
        )
    }
    
    private var image: UIImage {
        ImageBuilder(
            ImageGuideline(
                size: CGSize(width: 10, height: 10),
                cornersGuideline: .init(radius: 5, borderColor: nil)
            )
        )
            .setImageColor(status.color).build()
    }
    
    // MARK: - Unavailable
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
