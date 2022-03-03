import Foundation
import Combine
import SwiftProtobuf

public protocol BlockModelProtocol {
    var information: BlockInformation { get set }
    init(information: BlockInformation)

    var parent: BlockModelProtocol? { get set }
}
