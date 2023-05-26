import Foundation
import SwiftUI

protocol HomeSubmoduleProviderProtocol: AnyObject {
    @MainActor
    var view: AnyView { get }
    var componentId: String { get }
}
