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
        
        if FeatureFlags.bookmarksFlowP2 {
            contentView.layoutUsing.stack {
                $0.edgesToSuperview(insets: Layout.contentInsets)
            } builder: {
                $0.hStack(
                    icon,
                    $0.hGap(fixed: Layout.labelSpacing),
                    label,
                    $0.hGap(fixed: Layout.labelSpacing),
                    newActivityIndicator
                )
            }
        } else {
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
        }
    
        icon.layoutUsing.anchors {
            $0.width.equal(to: Layout.iconWidth)
            
        }
    }
    
    // MARK: - New configuration
    func apply(configuration: BlocksFileEmptyViewConfiguration) {
        icon.image = UIImage(asset: configuration.imageAsset)
        
        switch configuration.state {
        case .default:
            label.text = configuration.text
            activityIndicator.stopAnimating()
            newActivityIndicator.isHidden = true
            newActivityIndicator.stopAnimation()
        case .uploading:
            label.text = Constants.uploadingText
            activityIndicator.isHidden = false
            activityIndicator.startAnimating()
            newActivityIndicator.isHidden = false
            newActivityIndicator.startAnimation()
        case .error:
            label.text = Constants.errorText
            activityIndicator.stopAnimating()
            newActivityIndicator.isHidden = true
            newActivityIndicator.stopAnimation()
        }
    }
    
    private let contentView: UIView = {
        let view = UIView()
        view.layer.borderWidth = 0.5
        view.layer.borderColor = UIColor.strokePrimary.cgColor
        view.layer.cornerRadius = FeatureFlags.bookmarksFlowP2 ? 16 : 2
        view.clipsToBounds = true
        return view
    }()
    
    private let label: UILabel = {
        let label = UILabel()
        label.font = .bodyRegular
        label.textColor = .buttonActive
        return label
    }()
    
    private let icon: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
             
    private let activityIndicator: UIActivityIndicatorView = {
        let loader = UIActivityIndicatorView()
        loader.color = .buttonActive
        loader.hidesWhenStopped = true
        return loader
    }()
    
    private let newActivityIndicator = UIAnytypeActivityIndicator()
}


extension BlocksFileEmptyView {
    private enum Layout {
        static let contentInsets = UIEdgeInsets(top: 15, left: 16, bottom: 15, right: 18)
        static let labelSpacing: CGFloat = 10
        static let iconWidth: CGFloat =  22
    }
    
    private enum Constants {
        static let errorText = "Error, try again later"
        static let uploadingText = "Uploading..."
    }
}
