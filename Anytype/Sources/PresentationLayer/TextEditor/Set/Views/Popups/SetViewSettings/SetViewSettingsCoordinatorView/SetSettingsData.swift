import SwiftUI
import Services

struct SetSettingsData: Identifiable {
    let id = UUID()
    let setDocument: SetDocumentProtocol
    let viewId: String
    let subscriptionDetailsStorage: ObjectDetailsStorage
    let mode: SetViewSettingsMode
}
