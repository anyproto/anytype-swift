import Foundation
import SwiftUI

protocol HomeWidgetProviderProtocol: AnyObject {
    @MainActor
    var view: AnyView { get }
    var componentId: String { get }
}
