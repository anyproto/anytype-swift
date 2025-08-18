import Foundation
import Services
import SwiftUI

protocol ObjectOpenerProtocol: AnyObject {
    func openObject(objectId: String, spaceId: String)
}

final class ObjectOpenerWrapper: ObjectOpenerProtocol {
    
    weak var opener: (any ObjectOpenerProtocol)?
    
    init(opener: (any ObjectOpenerProtocol)? = nil) {
        self.opener = opener
    }

    func openObject(objectId: String, spaceId: String) {
        opener?.openObject(objectId: objectId, spaceId: spaceId)
    }
}

extension EnvironmentValues {
    @Entry var objectOpener: ObjectOpenerWrapper = ObjectOpenerWrapper()
}

extension View {
    func objectOpener(_ opener: any ObjectOpenerProtocol) -> some View {
        environment(\.objectOpener, ObjectOpenerWrapper(opener: opener))
    }
}
