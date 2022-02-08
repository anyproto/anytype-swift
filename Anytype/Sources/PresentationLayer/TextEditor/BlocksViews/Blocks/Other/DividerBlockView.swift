import UIKit
import Combine

class DividerBlockView: UIView {
    // MARK: Views
    private var contentView: UIView!
    
    private var lineView: UIView!
    private var dotsView: UIView!
    private var dotsImageViews: [UIImageView] = []
    
    private let dividerViewInsets = UIEdgeInsets(top: 6, left: 6, bottom: 6, right: 6)
    private let dividerHeight: CGFloat = 1
            
    // MARK: Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setup()
    }
    
    // MARK: Setup
    private func setup() {
        self.setupUIElements()
        self.addLayout()
    }
    
    // MARK: UI Elements
    private func setupUIElements() {
        self.translatesAutoresizingMaskIntoConstraints = false
        
        self.contentView = {
            let view = UIView()
            view.translatesAutoresizingMaskIntoConstraints = false
            return view
        }()
        
        self.lineView = {
            let view = UIView()
            view.backgroundColor = UIColor.Background.grey
            view.translatesAutoresizingMaskIntoConstraints = false
            return view
        }()
        
        self.dotsView = {
            let view = UIView()
            view.translatesAutoresizingMaskIntoConstraints = false
            /// Add imageViews
            let image = UIImage.divider.dots
            let leftImageView: UIImageView = .init(image: image)
            let centerImageView: UIImageView = .init(image: image)
            let rightImageView: UIImageView = .init(image: image)
            
            for view in [leftImageView, centerImageView, rightImageView] {
                view.contentMode = .center
                view.translatesAutoresizingMaskIntoConstraints = false
            }
            
            view.addSubview(leftImageView)
            view.addSubview(centerImageView)
            view.addSubview(rightImageView)
            
            self.dotsImageViews = [leftImageView, centerImageView, rightImageView]
            
            return view
        }()
                    
        self.contentView.addSubview(self.lineView)
        self.contentView.addSubview(self.dotsView)
        self.addSubview(self.contentView)
    }
    
    // MARK: Layout
    private func addLayout() {
        if let view = self.contentView, let superview = view.superview {
            NSLayoutConstraint.activate([
                view.leadingAnchor.constraint(equalTo: superview.leadingAnchor, constant: dividerViewInsets.left),
                view.trailingAnchor.constraint(equalTo: superview.trailingAnchor, constant: -dividerViewInsets.right),
                view.topAnchor.constraint(equalTo: superview.topAnchor, constant: dividerViewInsets.top),
                view.bottomAnchor.constraint(equalTo: superview.bottomAnchor, constant: -dividerViewInsets.bottom)
            ])
        }
        
        if let view = self.lineView, let superview = view.superview {
            NSLayoutConstraint.activate([
                view.leadingAnchor.constraint(equalTo: superview.leadingAnchor),
                view.trailingAnchor.constraint(equalTo: superview.trailingAnchor),
                view.topAnchor.constraint(equalTo: superview.topAnchor),
                view.bottomAnchor.constraint(equalTo: superview.bottomAnchor),
                view.heightAnchor.constraint(equalToConstant: dividerHeight)
            ])
        }
        
        if let view = self.dotsView, let superview = view.superview {
            NSLayoutConstraint.activate([
                view.leadingAnchor.constraint(equalTo: superview.leadingAnchor),
                view.trailingAnchor.constraint(equalTo: superview.trailingAnchor),
                view.topAnchor.constraint(equalTo: superview.topAnchor),
                view.bottomAnchor.constraint(equalTo: superview.bottomAnchor),
                view.heightAnchor.constraint(equalToConstant: dividerHeight)
            ])
        }
        
        let leftImageView = self.dotsImageViews[0]
        let centerImageView = self.dotsImageViews[1]
        let rightImageView = self.dotsImageViews[2]
        
        if let superview = centerImageView.superview {
            let view = centerImageView
            NSLayoutConstraint.activate([
                view.centerXAnchor.constraint(equalTo: superview.centerXAnchor),
                view.topAnchor.constraint(equalTo: superview.topAnchor),
                view.bottomAnchor.constraint(equalTo: superview.bottomAnchor)
            ])
        }
        
        if let superview = leftImageView.superview {
            let view = leftImageView
            let rightView = centerImageView
            NSLayoutConstraint.activate([
                view.topAnchor.constraint(equalTo: superview.topAnchor),
                view.bottomAnchor.constraint(equalTo: superview.bottomAnchor),
                view.leadingAnchor.constraint(greaterThanOrEqualTo: superview.leadingAnchor),
                view.trailingAnchor.constraint(equalTo: rightView.leadingAnchor, constant: -10)
            ])
        }
        
        if let superview = rightImageView.superview {
            let view = rightImageView
            let leftView = centerImageView
            NSLayoutConstraint.activate([
                view.topAnchor.constraint(equalTo: superview.topAnchor),
                view.bottomAnchor.constraint(equalTo: superview.bottomAnchor),
                view.leadingAnchor.constraint(equalTo: leftView.trailingAnchor, constant: 10),
                view.trailingAnchor.constraint(lessThanOrEqualTo: superview.trailingAnchor)
            ])
        }

    }
    
    // MARK: - Actions
    func toDotsView() {
        self.lineView.isHidden = true
        self.dotsView.isHidden = false
    }
    
    func toLineView() {
        self.lineView.isHidden = false
        self.dotsView.isHidden = true
    }
}
