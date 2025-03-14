import SwiftUI
import UIKit

enum HomeBlurEffectViewDirection {
    case topToBottom
    case bottomToTop
}

struct HomeBlurEffectView: UIViewRepresentable {
    
    let direction: HomeBlurEffectViewDirection
    
    func makeUIView(context: Context) -> HomeBlurEffectUIView {
        return HomeBlurEffectUIView()
    }
    
    func updateUIView(_ uiView: HomeBlurEffectUIView, context: Context) {
        uiView.direction = direction
    }
}

final class HomeBlurEffectUIView: UIView {
    
    private let maskGradientLayer: CAGradientLayer
    private let effectView: UIVisualEffectView
    private let transitionHeight: CGFloat = 10
    private var observerToken: (any NSObjectProtocol)?
    
    var direction: HomeBlurEffectViewDirection = .topToBottom
    
    override init(frame: CGRect) {
        maskGradientLayer = CAGradientLayer()
        maskGradientLayer.colors = [UIColor.black.cgColor as Any, UIColor.clear.cgColor as Any]

        effectView = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterial))
        
        super.init(frame: frame)
        setBlurRadius()
        
        addSubview(effectView) {
            $0.pinToSuperview()
        }
        
        effectView.layer.mask = maskGradientLayer
        
        observerToken = NotificationCenter.default.addObserver(
            forName: UIApplication.willEnterForegroundNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            MainActor.assumeIsolated {
                self?.setBlurRadius()
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        guard frame.height > 0 else { return }
        
        let percent = (frame.height - transitionHeight) / frame.height
        
        switch direction {
        case .topToBottom:
            maskGradientLayer.startPoint = CGPoint(x: 0, y: percent)
            maskGradientLayer.endPoint = CGPoint(x: 0, y: 1)
        case .bottomToTop:
            maskGradientLayer.endPoint = CGPoint(x: 0, y: 0)
            maskGradientLayer.startPoint = CGPoint(x: 0, y: 1 - percent)
        }
        maskGradientLayer.frame = bounds
    }
    
    private func setBlurRadius() {
        if let backgroundLayer = effectView.layer.sublayers?.first {
            backgroundLayer.filters?.removeAll { String(describing: $0) != "gaussianBlur" }
            let filter = backgroundLayer.filters?.last as? NSObject
            filter?.setValue(4, forKey: "inputRadius")
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        DispatchQueue.main.async { [weak self] in
            self?.setBlurRadius()
        }
    }
}
