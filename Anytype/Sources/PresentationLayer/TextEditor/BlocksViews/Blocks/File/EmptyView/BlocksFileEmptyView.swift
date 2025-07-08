import Combine
import Services
import UIKit
import AnytypeCore

class BlocksFileEmptyView: UIView, BlockContentView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    func update(with configuration: BlocksFileEmptyViewConfiguration) {
        apply(configuration: configuration)
    }
    
    private func setup() {
        addSubview(contentView) {
            $0.height.equal(to: 52)
            $0.pinToSuperview()
        }
        
        contentView.layoutUsing.stack {
            $0.edgesToSuperview(insets: Layout.contentInsets)
        } builder: {
            $0.hStack(
                icon,
                $0.hGap(fixed: Layout.labelLeftSpacing),
                label,
                $0.hGap(fixed: Layout.labelRighSpacing),
                activityIndicator
            )
        }
    
        icon.layoutUsing.anchors {
            $0.width.equal(to: Layout.iconWidth)
            
        }
    }
    
    // MARK: - New configuration
    func apply(configuration: BlocksFileEmptyViewConfiguration) {
        icon.image = UIImage(asset: configuration.imageAsset)
        label.text = configuration.text
        
        switch configuration.state {
        case .default:
            activityIndicator.stopAnimation()
            label.textColor = .Control.active
            icon.tintColor = .Control.active
        case .uploading:
            activityIndicator.startAnimation()
            label.textColor = .Control.active
            icon.tintColor = .Control.active
        case .error:
            activityIndicator.stopAnimation()
            label.textColor = .Pure.red
            icon.tintColor = .Pure.red
        }
    }
    
    private let contentView: UIView = {
        let view = UIView()
        view.layer.borderWidth = 0.5
        view.dynamicBorderColor = UIColor.Shape.primary
        view.layer.cornerRadius = 16
        view.clipsToBounds = true
        return view
    }()
    
    private let label: UILabel = {
        let label = UILabel()
        label.font = .bodyRegular
        label.textColor = .Control.active
        return label
    }()
    
    private let icon: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let activityIndicator: UIAnytypeActivityIndicator = {
        let loader = UIAnytypeActivityIndicator()
        loader.hidesWhenStopped = true
        return loader
    }()
}


extension BlocksFileEmptyView {
    private enum Layout {
        static let contentInsets = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 16)
        static let labelLeftSpacing: CGFloat = 4
        static let labelRighSpacing: CGFloat = 8
        static let iconWidth: CGFloat = 32
    }
}
