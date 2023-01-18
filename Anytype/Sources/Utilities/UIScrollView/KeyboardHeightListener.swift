import UIKit
import Combine

class KeyboardHeightListener {

    struct AnimationAction {
        let rect: CGRect
        let duration: TimeInterval
        let options: UIView.AnimationOptions
    }
    
    @Published var currentKeyboardHeight: CGFloat = 0
    @Published var currentKeyboardFrame: CGRect = .zero
    
    private let animationChangeSubject = PassthroughSubject<AnimationAction, Never>()
    lazy var animationChangePublisher = animationChangeSubject.eraseToAnyPublisher()
    
    private var keyboardListenerHelper: KeyboardEventsListnerHelper?

    init() {
        self.keyboardListenerHelper = KeyboardEventsListnerHelper(
            willShowAction: { [weak self] event in
                guard let keyboardRect = event.endFrame else { return }

                self?.currentKeyboardHeight = keyboardRect.height
                self?.currentKeyboardFrame = keyboardRect
                
                let animationAction = AnimationAction(
                    rect: keyboardRect,
                    duration: event.animationDuration ?? 0,
                    options: event.animationCurve ?? []
                )
                self?.animationChangeSubject.send(animationAction)
            },
            willChangeFrame: { [weak self] event in
                guard let keyboardRect = event.endFrame else { return }
                let animationAction = AnimationAction(
                    rect: keyboardRect,
                    duration: event.animationDuration ?? 0,
                    options: event.animationCurve ?? []
                )
                self?.animationChangeSubject.send(animationAction)
            },
            didChangeFrame: { [weak self] event in
                guard let keyboardRect = event.endFrame else { return }

                self?.currentKeyboardHeight = keyboardRect.height
                self?.currentKeyboardFrame = keyboardRect
            },
            willHideAction: { [weak self] event in
                self?.currentKeyboardHeight = 0
                self?.currentKeyboardFrame = .zero
                
                let animationAction = AnimationAction(
                    rect: .zero,
                    duration: event.animationDuration ?? 0,
                    options: event.animationCurve ?? []
                )
                self?.animationChangeSubject.send(animationAction)
            }
        )
    }
}
