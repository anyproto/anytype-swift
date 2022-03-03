import Foundation
import Combine
import SwiftProtobuf
import ProtobufMessages


public final class BlockModel: ObservableObject, BlockModelProtocol {
    @Published public var information: BlockInformation

    public required init(information: BlockInformation) {
        self.information = information
    }
}
