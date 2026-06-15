import Foundation
import Services
import AnytypeCore
import AsyncTools

protocol RemainingSpacesPreloadServiceProtocol: AnyObject, Sendable {
    func schedulePreload()
}

// AccountSelect with a non-empty preferredSpaceId makes the middleware load only that space eagerly.
// Once the cold start destination screen is shown, this call tells it to load the remaining spaces.
// One shot per process; errors are benign — the middleware has its own timer fallback.
final class RemainingSpacesPreloadService: RemainingSpacesPreloadServiceProtocol, Sendable {

    private let authMiddleService: any AuthMiddleServiceProtocol = Container.shared.authMiddleService()
    private let scheduled = AtomicStorage(false)

    func schedulePreload() {
        guard FeatureFlags.preferredSpaceOnColdStart else { return }

        let alreadyScheduled = scheduled.access { value in
            let wasScheduled = value
            value = true
            return wasScheduled
        }
        guard !alreadyScheduled else { return }

        Task {
            try? await Task.sleep(seconds: 2)
            try? await authMiddleService.preloadRemainingSpaces()
        }
    }
}
