import Combine
import UIKit
import BlocksModels
    
final class BlockBookmarkView: UIView, BlockContentView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    func update(with configuration: BlockBookmarkConfiguration) {
        apply(payload: configuration.payload)
    }

    private func setup() {
        addSubview(backgroundView) {
            $0.pinToSuperview(insets: Layout.backgroundViewInsets)
        }
    }
    
    private func apply(payload: BlockBookmarkPayload) {
        backgroundView.removeAllSubviews()
        
        guard !payload.imageHash.isEmpty else {
            layoutWithoutImage(payload: payload)
            return
        }
        
        informationView.update(payload: payload)
        imageView.update(imageId: payload.imageHash)
        
        backgroundView.addSubview(informationView) {
            $0.pinToSuperview(excluding: [.right])
        }
        
        backgroundView.addSubview(imageView) {
            $0.leading.equal(to: informationView.trailingAnchor)
            $0.trailing.equal(to: backgroundView.trailingAnchor, constant: -16)
            $0.centerY.equal(to: backgroundView.centerYAnchor)
        }
    }
    
    private func layoutWithoutImage(payload: BlockBookmarkPayload) {
        informationView.update(payload: payload)
        backgroundView.addSubview(informationView) {
            $0.pinToSuperview()
        }
    }

    // MARK: - Views
    private let informationView = BlockBookmarkInfoView()
    private let imageView = BlockBookmarkImageView()
    private let backgroundView: UIView = {
        let view = UIView()
        view.layer.borderWidth = 0.5
        view.layer.borderColor = UIColor.strokePrimary.cgColor
        view.layer.cornerRadius = 16
        view.clipsToBounds = true
        return view
    }()
}

private extension BlockBookmarkView {
    enum Layout {
        static let backgroundViewInsets = UIEdgeInsets(top: 10, left: 0, bottom: -10, right: 0)
    }
}
