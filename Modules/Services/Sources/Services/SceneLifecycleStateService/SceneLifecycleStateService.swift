import Foundation
import ProtobufMessages
import AnytypeCore

public protocol SceneLifecycleStateServiceProtocol: Sendable {
    func handleStateTransition(_ transition: LifecycleStateTransition)
}

/// Middleware should know about current app state in order to correctly handling socket listening
/// @see https://developer.apple.com/library/archive/technotes/tn2277/_index.html#//apple_ref/doc/uid/DTS40010841-CH1-SUBSECTION2
final class SceneLifecycleStateService: SceneLifecycleStateServiceProtocol {

    private let transitionContinuation: AsyncStream<LifecycleStateTransition>.Continuation

    init() {
        let (transitions, transitionContinuation) = AsyncStream<LifecycleStateTransition>.makeStream(bufferingPolicy: .unbounded)
        self.transitionContinuation = transitionContinuation

        // Transitions are reported one at a time because invocations run on a concurrent queue:
        // parallel tasks could deliver a quick background/foreground pair reversed, leaving
        // middleware treating a foreground app as backgrounded and skipping the resume head-sync.
        Task {
            for await transition in transitions {
                await Self.report(transition: transition)
            }
        }
    }

    deinit {
        transitionContinuation.finish()
    }

    // MARK: - SceneLifecycleStateServiceProtocol

    public func handleStateTransition(_ transition: LifecycleStateTransition) {
        transitionContinuation.yield(transition)
    }

    // MARK: - Private

    private static func report(transition: LifecycleStateTransition) async {
        let deviceState: Anytype_Rpc.App.SetDeviceState.Request.DeviceState = {
            switch transition {
            case .willEnterForeground: return .foreground
            case .didEnterBackground: return .background
            }
        }()

        _ = try? await ClientCommands.appSetDeviceState(.with {
            $0.deviceState = deviceState
        }).invoke()
    }
}
