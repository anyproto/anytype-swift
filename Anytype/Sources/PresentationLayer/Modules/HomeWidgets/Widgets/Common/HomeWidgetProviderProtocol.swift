import Foundation
import SwiftUI

@MainActor
protocol HomeWidgetProviderProtocol: AnyObject {
    var view: AnyView { get }
    var componentId: String { get }
}
