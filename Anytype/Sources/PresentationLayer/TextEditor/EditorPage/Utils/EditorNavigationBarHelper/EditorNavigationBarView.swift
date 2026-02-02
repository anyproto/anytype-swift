import Foundation
import UIKit

final class EditorNavigationBarView: UIView {

    private let glassContainer = GlassContainerViewIOS26(spacing: 12)
    private let leftButtonContainer = UIView()
    private let rightButtonContainer = UIView()
    private let titleContainer = UIView()
    private let contentView = UIView()
    private let bannerContainer = UIView()
    
    var leftButton: UIView? {
        didSet {
            leftButtonContainer.removeAllSubviews()
            if let leftButton {
                leftButtonContainer.addSubview(leftButton) {
                    $0.pinToSuperview()
                }
            }
        }
    }
    
    var rightButton: UIView? {
        didSet {
            rightButtonContainer.removeAllSubviews()
            if let rightButton {
                rightButtonContainer.addSubview(rightButton) {
                    $0.pinToSuperview()
                }
            }
        }
    }
    
    var titleView: UIView? {
        didSet {
            titleContainer.removeAllSubviews()
            if let titleView {
                titleContainer.addSubview(titleView) {
                    $0.pinToSuperview()
                }
            }
        }
    }
    
    var bannerView: UIView? {
        didSet {
            bannerContainer.removeAllSubviews()
            if let bannerView {
                bannerContainer.addSubview(bannerView) {
                    $0.pinToSuperview()
                }
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(glassContainer) {
            $0.pinToSuperview(excluding: [.bottom], insets: UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16))
            $0.height.equal(to: 44)
        }

        glassContainer.glassContentView.addSubview(contentView) {
            $0.pinToSuperview()
        }

        addSubview(bannerContainer) {
            $0.pinToSuperview(excluding: [.top], insets: UIEdgeInsets(top: 0, left: 16, bottom: 8, right: 16))
            $0.top.equal(to: glassContainer.bottomAnchor, constant: 8)
        }
        
        contentView.addSubview(leftButtonContainer) {
            $0.centerY.equal(to: contentView.centerYAnchor)
            $0.leading.equal(to: contentView.leadingAnchor)
        }
        
        contentView.addSubview(rightButtonContainer) {
            $0.centerY.equal(to: contentView.centerYAnchor)
            $0.trailing.equal(to: contentView.trailingAnchor)
        }
        
        contentView.addSubview(titleContainer) {
            $0.centerY.equal(to: contentView.centerYAnchor)
            $0.leading.equal(to: leftButtonContainer.trailingAnchor, constant: 8)
            $0.trailing.equal(to: rightButtonContainer.leadingAnchor, constant: -8)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
