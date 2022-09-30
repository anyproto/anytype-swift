import UIKit
import Combine

final class AnytypeWindow: UIWindow {
    enum Constants {
        static let textRangeViewClass: AnyClass? = NSClassFromString("UITextRangeView")
    }

    let textRangeTouchSubject = PassthroughSubject<UITouch, Never>()

    static private(set) var shared: AnytypeWindow?

    private weak var textRangeTouch: UITouch?

    // MARK: - Init

    override init(windowScene: UIWindowScene) {
        super.init(windowScene: windowScene)

        Self.shared = self
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        Self.shared = self
    }

    // MARK: - 

    override func sendEvent(_ event: UIEvent) {
        event.allTouches?.forEach { touch in
            touch.gestureRecognizers?.forEach { recognizer in
                guard let view = recognizer.view, let className = Constants.textRangeViewClass else { return }
                if view.isKind(of: className) {

                    textRangeTouch = touch
                }
            }
        }

        super.sendEvent(event)

        textRangeTouch.map { textRangeTouchSubject.send($0) }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)

        textRangeTouch = nil
    }
}
