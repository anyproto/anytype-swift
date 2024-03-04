import Foundation
import ProtobufMessages
import AnytypeCore

public protocol SceneLifecycleStateServiceProtocol {
    func handleStateTransition(_ transition: LifecycleStateTransition)
}

/// Middleware should know about current app state in order to correctly handling socket listening
/// @see https://developer.apple.com/library/archive/technotes/tn2277/_index.html#//apple_ref/doc/uid/DTS40010841-CH1-SUBSECTION2
 final class SceneLifecycleStateService: SceneLifecycleStateServiceProtocol {
    
    // MARK: - SceneLifecycleStateServiceProtocol
    
    public func handleStateTransition(_ transition: LifecycleStateTransition) {
        let deviceState: Anytype_Rpc.App.SetDeviceState.Request.DeviceState = {
            switch transition {
            case .willEnterForeground: return .foreground
            case .didEnterBackground: return .background
            }
        }()
		
		Task { @MainActor in
			_ = try? await ClientCommands.appSetDeviceState(.with {
				$0.deviceState = deviceState
			}).invoke()
		}
    }
    
}

