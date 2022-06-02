import UIKit
import Combine

struct BlockFileMediaData: Hashable {
    let size: String
    let name: String
    let iconImageName: String
}

final class BlockFileView: UIView, BlockContentView {

    private let dividerView = DividerBlockView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    func update(with configuration: BlockFileConfiguration) {
        handle(data: configuration.data)
    }

    func setup() {
        layoutUsing.anchors { $0.height.equal(to: 32) }
        addSubview(contentView) {
            $0.pinToSuperview()
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
        imageView.image = UIImage(named: data.iconImageName)
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
}
