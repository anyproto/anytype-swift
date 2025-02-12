import UIKit
import AnytypeCore

extension Notification: @unchecked @retroactive Sendable {}

@MainActor
class KeyboardEventsListnerHelper {
    
    typealias Action = (KeyboardEvent) -> Void
    private var observerTokens: [any NSObjectProtocol]?
    private var keyboardState = KeyboardState.hidden
    
    deinit {
        Task { @MainActor [observerTokens] in
            observerTokens?.forEach { NotificationCenter.default.removeObserver($0) }
        }
    }
    
    init?(
        willShowAction: Action? = nil,
        didShowAction: Action? = nil,
        willChangeFrame: Action? = nil,
        didChangeFrame: Action? = nil,
        willHideAction: Action? = nil,
        didHideAction: Action? = nil
    ) {

        guard ![didHideAction, willChangeFrame, didChangeFrame, willHideAction, didHideAction].compactMap({ $0 }).isEmpty else {
            anytypeAssertionFailure("No arguments passed")
            return nil
        }

        let entities = [
            UIResponder.keyboardWillShowNotification: actionWrapper(
                allowedStates: [.hidden],
                newState: .appearing,
                originalAction: willShowAction
            ),
            UIResponder.keyboardDidShowNotification: actionWrapper(
                allowedStates: [.disappearing, .appearing],
                newState: .shown,
                originalAction: didShowAction
            ),
            UIResponder.keyboardWillHideNotification: actionWrapper(
                allowedStates: [.appearing, .shown],
                newState: .disappearing,
                originalAction: willHideAction
            ),
            UIResponder.keyboardDidHideNotification: actionWrapper(
                allowedStates: [.disappearing],
                newState: .hidden,
                originalAction: didHideAction
            ),
            UIResponder.keyboardWillChangeFrameNotification: actionWrapper(
                allowedStates: [.shown],
                newState: .shown,
                originalAction: willChangeFrame
            ),
            UIResponder.keyboardDidChangeFrameNotification: actionWrapper(
                allowedStates: [.shown],
                newState: .shown,
                originalAction: didChangeFrame
            )
        ]
        observerTokens = entities.map { name, action in
            return NotificationCenter.default.addObserver(
                forName: name,
                object: nil,
                queue: .main,
                using: action
            )
        }
    }
    
    private func actionWrapper(
        allowedStates: [KeyboardState],
        newState: KeyboardState,
        originalAction: Action?
    ) -> @Sendable (Notification) -> Void {
        return { [weak self] notification in
            MainActor.assumeIsolated {
                guard let self = self else { return }
                if allowedStates.contains(self.keyboardState) {
                    if let event = KeyboardEvent(withUserInfo: notification.userInfo) {
                        originalAction?(event)
                    }
                    self.keyboardState = newState
                }
            }
        }
    }
}
