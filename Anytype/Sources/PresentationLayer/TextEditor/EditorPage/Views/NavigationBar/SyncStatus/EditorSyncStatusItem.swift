import UIKit
import Services

final class EditorSyncStatusItem: UIView {
    private lazy var button: UIButton = {
        let configuration = UIButton.Configuration.plain()
        
        return UIButton(
            configuration: configuration,
            primaryAction: UIAction(
                title: "",
                handler: { [weak self] _ in
                    UISelectionFeedbackGenerator().selectionChanged()
                    self?.onTap()
                }
            )
        )
    }()
    
    private let backgroundView = UIView()
    
    private var statusData: SyncStatusData?
    private var itemState: EditorBarItemState?
    
    private let onTap: () -> ()
    
    private let height: CGFloat = 28
    private let width: CGFloat = 28
    private var intristicSize: CGSize = .zero
    
    func changeStatusData(_ statusData: SyncStatusData?) {
        self.statusData = statusData
        self.updateButtonState()
    }
    
    func changeItemState(_ itemState: EditorBarItemState) {
        self.itemState = itemState
        self.updateBackgroundColor()
    }
    
    init(statusData: SyncStatusData? = nil, itemState: EditorBarItemState? = nil, onTap: @escaping () -> ()) {
        self.statusData = statusData
        self.onTap = onTap
        super.init(frame: .zero)
        setup()
    }
    
    override var intrinsicContentSize: CGSize {
        intristicSize
    }
    
    // MARK: - Private
    
    private func setup() {
        updateButtonState()
        updateBackgroundColor()
        
        layoutUsing.anchors {
            $0.height.equal(to: height)
            $0.width.equal(to: width)
            $0.centerY.equal(to: centerYAnchor)
        }
        
        backgroundView.layer.cornerRadius = 7
        
        addSubview(backgroundView) { $0.pinToSuperview() }
        addSubview(button) { $0.pinToSuperview() }
    }
    
    private func updateBackgroundColor() {
        guard let haveBackground = itemState?.haveBackground else {
            backgroundView.backgroundColor = .clear
            return
        }
        
        backgroundView.backgroundColor = haveBackground ? .black.withAlphaComponent(0.35) : .clear
    }

    private func updateButtonState() {
        isHidden = statusData?.isHidden ?? true
        button.layer.removeAllAnimations()
        
        switch statusData?.icon {
        case .image(let newImage):
            animateImageChange(newImage)
        case .animation(let animationStart, let animationEnd):
            startRepeatingAnimation(animationStart, animationEnd)
        case nil:
            button.setImage(nil, for: .normal)
        }
    }
    
    private func animateImageChange(_ newImage: UIImage, completion: @escaping () -> () = {}) {
        UIView.transition(with: button, duration: 0.3, options: [.transitionCrossDissolve, .allowUserInteraction], animations: {
            self.button.setImage(newImage, for: .normal)
        }, completion: { _ in completion() })
    }
    
    private func startRepeatingAnimation(_ animationStart: UIImage, _ animationEnd: UIImage) {
        Task { @MainActor [weak self, statusData] in
            guard let self else { return }
            guard self.statusData?.status == statusData?.status else { return }
            
            button.layer.removeAllAnimations()
            animateImageChange(animationStart) {
                UIView.transition(with: self.button, duration: 1.5, options: [.transitionCrossDissolve, .autoreverse, .repeat, .allowUserInteraction]) {
                    self.button.setImage(animationEnd, for: .normal)
                }
            }
        }
    }
    
    // MARK: - Unavailable
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
