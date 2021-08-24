import UIKit
import Combine

struct BlockFileMediaData: Hashable {
    var size: String
    var name: String
    var typeIcon: UIImage
}

class BlockFileView: UIView & UIContentView {
    private var currentConfiguration: BlockFileConfiguration
    
    init(configuration: BlockFileConfiguration) {
        self.currentConfiguration = configuration
        super.init(frame: .zero)
        
        setup()
        handle(data: configuration.data)
    }
    
    @available(*, unavailable)
    override init(frame: CGRect) {
        fatalError("Not implemented")
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setup() {
        layoutUsing.anchors { $0.height.equal(to: 32) }
        addSubview(contentView) {
            $0.pinToSuperview(insets: UIEdgeInsets(top: 1, left: 20, bottom: -1, right: -20))
        }
    
        contentView.layoutUsing.stack {
            $0.hStack(
                $0.hGap(fixed: 3),
                imageView,
                $0.hGap(fixed: 7),
                titleView,
                $0.hGap(fixed: 10),
                sizeView,
                $0.hGap()
            )
        }
        
        imageView.layoutUsing.anchors {
            $0.width.equal(to: 18)
        }
        
        translatesAutoresizingMaskIntoConstraints = true
    }
    
    func handle(data: BlockFileMediaData) {
        titleView.text = data.name
        imageView.image = data.typeIcon
        sizeView.text = data.size
    }
    
    // MARK: - Views
    let contentView = UIView()
    
    let imageView: UIImageView  = {
        let view = UIImageView()
        view.contentMode = .center
        return view
    }()
    
    let titleView: UILabel = {
        let view = UILabel()
        view.font = .bodyRegular
        view.textColor = .textPrimary
        return view
    }()
    
    let sizeView: UILabel = {
        let view = UILabel()
        view.font = .calloutRegular
        view.textColor = . textSecondary
        return view
    }()
    
    // MARK: - UIContentView
    var configuration: UIContentConfiguration {
        get { currentConfiguration }
        set {
            guard let configuration = newValue as? BlockFileConfiguration else { return }
            guard self.currentConfiguration != configuration else { return }
            self.currentConfiguration = configuration
            
            handle(data: currentConfiguration.data)
        }
    }
}
