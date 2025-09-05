import UIKit
import Cache

final class MessageTextUIView: UIView {
    
    // MARK: - Private properties
    
    private lazy var textLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var infoLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = MessageTextViewData.infoLineLimit
        return label
    }()
    
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
        textLabel.attributedText = data?.message
        infoLabel.attributedText = data?.infoText
    }
    
    private func updateLayout() {
        textLabel.addTo(parent: self, frame: layout?.textFrame)
        infoLabel.addTo(parent: self, frame: layout?.infoFrame)
    }
}
