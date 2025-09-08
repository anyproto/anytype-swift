import UIKit
import Cache
import DesignKit

final class MessageTextUIView: UIView {
    
    // MARK: - Private properties
    
    private lazy var textLabel: TappableLabel = {
        let label = TappableLabel()
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var infoLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = MessageTextViewData.infoLineLimit
        return label
    }()
    
    private lazy var syncIcon = UIImageView()
    
    // MARK: - Public properties
    
    var data: MessageTextViewData? {
        didSet {
            if data != oldValue {
                updateData()
            }
        }
    }
    
    var layout: MessageTextLayout? {
        didSet {
            if layout != oldValue {
                updateLayout()
            }
        }
    }
    
    // MARK: - Pulic
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        return layout?.size ?? .zero
    }
    
    // MARK: - Private
    
    private func updateData() {
        guard let data else { return }
        let infoColor: UIColor = data.position.isRight ? .Background.Chat.whiteTransparent : .Control.transparentSecondary
        textLabel.attributedText = data.message
        infoLabel.attributedText = data.infoText
        infoLabel.textColor = infoColor
        if let synced = data.synced {
            syncIcon.image = UIImage(asset: synced ? .MessageStatus.synced : .MessageStatus.loading)
            syncIcon.tintColor = infoColor
        } else {
            syncIcon.image = nil
        }
    }
    
    private func updateLayout() {
        textLabel.addTo(parent: self, frame: layout?.textFrame)
        infoLabel.addTo(parent: self, frame: layout?.infoFrame)
        syncIcon.addTo(parent: self, frame: layout?.syncIconFrame)
    }
}
