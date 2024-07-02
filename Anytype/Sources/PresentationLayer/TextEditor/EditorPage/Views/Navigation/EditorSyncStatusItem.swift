import UIKit
import Services

final class EditorSyncStatusItem: UIView {
    private let button: UIButton = {
        let configuration = UIButton.Configuration.plain()
        
        return UIButton(configuration: configuration)
    }()
    
    private var statusData: SyncStatusData?
    
    private let height: CGFloat = 28
    private let width: CGFloat = 28
    private var intristicSize: CGSize = .zero
    
    func changeStatusData(_ statusData: SyncStatusData) {
        self.statusData = statusData
        self.updateButtonState()
    }
    
    init(statusData: SyncStatusData? = nil) {
        self.statusData = statusData
        super.init(frame: .zero)
        setup()
    }
    
    override var intrinsicContentSize: CGSize {
        intristicSize
    }
    
    // MARK: - Private
    
    private func setup() {
        button.showsMenuAsPrimaryAction = true
        
        updateButtonState()
        
        layoutUsing.anchors {
            $0.height.equal(to: height)
            $0.width.equal(to: width)
            $0.centerY.equal(to: centerYAnchor)
        }
        
        addSubview(button) { $0.pinToSuperview() }
    }
    
    private func updateButtonState() {
        isHidden = statusData?.isHidden ?? true
        button.layer.removeAllAnimations()
        
        switch statusData?.icon {
        case .image(let newImage):
            animateImageChange(newImage)
        case .animation(let animationStart, let animationEnd):
            animateImageChange(animationStart)
            startRepeatingAnimation(animationEnd)
        case nil:
            button.setImage(nil, for: .normal)
        }
    }
    
    private func animateImageChange(_ newImage: UIImage) {
        UIView.transition(with: button, duration: 0.3, options: [.transitionCrossDissolve]) {
            self.button.setImage(newImage, for: .normal)
        }
    }
    
    private func startRepeatingAnimation(_ newImage: UIImage) {
        Task { @MainActor [weak self, statusData] in
            guard let self else { return }
            guard self.statusData?.status == statusData?.status else { return }
            
            button.layer.removeAllAnimations()
            UIView.transition(with: button, duration: 1.5, options: [.transitionCrossDissolve, .autoreverse, .repeat]) {
                self.button.setImage(newImage, for: .normal)
            }
        }
    }
    
    // MARK: - Unavailable
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
