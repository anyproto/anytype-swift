import Combine
import UIKit
import BlocksModels
import AnytypeCore

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
        backgroundView.backgroundColor = configuration.backgroundColor

        apply(payload: configuration.payload)
    }

    private func setup() {
        addSubview(backgroundView) {
            $0.pinToSuperview(insets: Layout.backgroundViewInsets)
        }
    }
    
    private func apply(payload: BlockBookmarkPayload) {
        backgroundView.removeAllSubviews()
        
        if payload.imageHash.isEmpty {
            layoutWithoutImage(payload: payload)
        } else {
            layoutWithImage(payload: payload)
        }
        
        if FeatureFlags.bookmarksFlowP2 {
            layoutArchiveLabel(payload: payload)
        }
    }
    
    private func layoutWithoutImage(payload: BlockBookmarkPayload) {
        informationView.update(payload: payload)
        backgroundView.addSubview(informationView) {
            $0.pinToSuperview()
        }
    }
    
    private func layoutWithImage(payload: BlockBookmarkPayload) {
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
    
    private func layoutArchiveLabel(payload: BlockBookmarkPayload) {
        if payload.isArchived {
            backgroundView.addSubview(deletedLabel) {
                $0.pinToSuperview(excluding: [.left, .bottom], insets: Layout.deletedInsets)
            }
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
        view.backgroundColor = .clear
        return view
    }()
    private let deletedLabel = DeletedLabel()
}

private extension BlockBookmarkView {
    enum Layout {
        static let backgroundViewInsets = UIEdgeInsets(top: 10, left: 0, bottom: -10, right: 0)
        static let deletedInsets = UIEdgeInsets(top: 8, left: 0, bottom: 0, right: -8)
    }
}
