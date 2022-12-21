import Combine
import BlocksModels
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
                $0.hGap(fixed: Layout.labelSpacing),
                label,
                $0.hGap(fixed: Layout.labelSpacing),
                activityIndicator
            )
        }
    
        icon.layoutUsing.anchors {
            $0.width.equal(to: Layout.iconWidth)
            
        }
    }
    
    // MARK: - New configuration
    func apply(configuration: BlocksFileEmptyViewConfiguration) {
        icon.image = UIImage(asset: configuration.imageAsset)?.withRenderingMode(.alwaysTemplate)
        label.text = configuration.text
        
        switch configuration.state {
        case .default:
            activityIndicator.stopAnimation()
            label.textColor = .Button.active
            icon.tintColor = .Button.active
        case .uploading:
            activityIndicator.startAnimation()
            label.textColor = .Button.active
            icon.tintColor = .Button.active
        case .error:
            activityIndicator.stopAnimation()
            label.textColor = .System.red
            icon.tintColor = .System.red
        }
    }
    
    private let contentView: UIView = {
        let view = UIView()
        view.layer.borderWidth = 0.5
        view.dynamicBorderColor = UIColor.Stroke.primary
        view.layer.cornerRadius = 16
        view.clipsToBounds = true
        return view
    }()
    
    private let label: UILabel = {
        let label = UILabel()
        label.font = .bodyRegular
        label.textColor = .Button.active
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
        static let contentInsets = UIEdgeInsets(top: 15, left: 16, bottom: 15, right: 18)
        static let labelSpacing: CGFloat = 10
        static let iconWidth: CGFloat =  22
    }
}
