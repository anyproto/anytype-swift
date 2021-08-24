import Combine
import UIKit
import BlocksModels
    
final class BlockBookmarkView: UIView & UIContentView {
    private var currentConfiguration: BlockBookmarkConfiguration
    
    init(configuration: BlockBookmarkConfiguration) {
        self.currentConfiguration = configuration
        super.init(frame: .zero)
        
        setup()
        apply(payload: currentConfiguration.payload)
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
        view.layer.borderColor = UIColor.stroke.cgColor
        view.layer.cornerRadius = 16
        view.clipsToBounds = true
        return view
    }()
    
    // MARK: - UIContentView
    var configuration: UIContentConfiguration {
        get { currentConfiguration }
        set {
            guard let configuration = newValue as? BlockBookmarkConfiguration,
                  configuration != currentConfiguration else { return }
            
            currentConfiguration = configuration
            apply(payload: currentConfiguration.payload)
        }
    }
    
    // MARK: - Unavailable
    @available(*, unavailable)
    override init(frame: CGRect) {
        fatalError("Not implemented")
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension BlockBookmarkView {
    enum Layout {
        static let backgroundViewInsets = UIEdgeInsets(top: 10, left: 20, bottom: -10, right: -20)
    }
}
