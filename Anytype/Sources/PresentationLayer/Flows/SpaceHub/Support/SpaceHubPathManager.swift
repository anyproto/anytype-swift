import Foundation
import AsyncTools
import Factory

protocol SpaceHubPathUXTypeHelperProtocol: AnyObject, Sendable {
    func updateNaivgationPathForUxType(spaceView: SpaceView, path: HomePath) async -> HomePath
}

final class SpaceHubPathUXTypeHelper: SpaceHubPathUXTypeHelperProtocol {
        
    func updateNaivgationPathForUxType(spaceView: SpaceView, path: HomePath) async -> HomePath {
        await Task.detached {
            var path = path
            switch spaceView.uxType {
            case .chat:
                // Expected: SpaceHubNavigationItem, SpaceChatCoordinatorData
                let chatItem = SpaceChatCoordinatorData(spaceId: spaceView.targetSpaceId)
                path.remove(chatItem)
                path.insert(chatItem, at: 1)
            case .data:
                // Expected: SpaceHubNavigationItem, HomeWidgetData
                let chatItem = SpaceChatCoordinatorData(spaceId: spaceView.targetSpaceId)
                let homeItem = HomeWidgetData(spaceId: spaceView.targetSpaceId)
                path.remove(chatItem)
                path.remove(homeItem)
                path.insert(homeItem, at: 1)
            default:
                break
            }
            return path
        }.value
    }
}

extension Container {
    var spaceHubPathUXTypeHelper: Factory<any SpaceHubPathUXTypeHelperProtocol> {
        self { SpaceHubPathUXTypeHelper() }
    }
}
