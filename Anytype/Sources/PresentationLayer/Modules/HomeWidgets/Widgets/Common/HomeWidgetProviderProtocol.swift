import Foundation
import SwiftUI

@MainActor
protocol HomeWidgetProviderProtocol: AnyObject {
    func view() -> AnyView
    func componentId() -> String
}
