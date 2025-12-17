import Foundation
import AsyncTools
import Factory

protocol SpaceHubPathUXTypeHelperProtocol: AnyObject, Sendable {
    func updateNaivgationPathForUxType(spaceView: SpaceView, path: HomePath) async -> HomePath
}

final class SpaceHubPathUXTypeHelper: SpaceHubPathUXTypeHelperProtocol {
        
    func updateNaivgationPathForUxType(spaceView: SpaceView, path: HomePath) async -> HomePath {
        return path
    }
}

extension Container {
    var spaceHubPathUXTypeHelper: Factory<any SpaceHubPathUXTypeHelperProtocol> {
        self { SpaceHubPathUXTypeHelper() }
    }
}
