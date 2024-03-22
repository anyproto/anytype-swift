import Combine
import SwiftUI

final class AppActionStorage: ObservableObject {
    @Published var action: AppAction?
}
