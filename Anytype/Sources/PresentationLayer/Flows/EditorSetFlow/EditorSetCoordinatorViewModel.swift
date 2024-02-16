import Foundation
import Services
import SwiftUI

@MainActor
final class EditorSetCoordinatorViewModel: ObservableObject, EditorSetModuleOutput {
    
    private let data: EditorSetObject
    private let editorSetAssembly: EditorSetModuleAssemblyProtocol
    private let setViewPickerCoordinatorAssembly: SetViewPickerCoordinatorAssemblyProtocol
    private let setViewSettingsCoordinatorAssembly: SetViewSettingsCoordinatorAssemblyProtocol
    
    var pageNavigation: PageNavigation?
    @Published var dismiss = false
    
    @Published var setViewPickerData: SetViewData?
    @Published var setViewSettingsData: SetViewData?
    
    init(
        data: EditorSetObject,
        editorSetAssembly: EditorSetModuleAssemblyProtocol,
        setViewPickerCoordinatorAssembly: SetViewPickerCoordinatorAssemblyProtocol,
        setViewSettingsCoordinatorAssembly: SetViewSettingsCoordinatorAssemblyProtocol
    ) {
        self.data = data
        self.editorSetAssembly = editorSetAssembly
        self.setViewPickerCoordinatorAssembly = setViewPickerCoordinatorAssembly
        self.setViewSettingsCoordinatorAssembly = setViewSettingsCoordinatorAssembly
    }
    
    func setModule() -> AnyView {
        editorSetAssembly.make(data: data, output: self)
    }
    
    // MARK: - EditorSetModuleOutput
    
    func showEditorScreen(data: EditorScreenData) {
        pageNavigation?.push(data)
    }
    
    func replaceEditorScreen(data: EditorScreenData) {
        pageNavigation?.replace(data)
    }
    
    func closeEditor() {
        dismiss.toggle()
    }
    
    // MARK: - EditorSetModuleOutput - SetViewPicker
    
    func showSetViewPicker(document: SetDocumentProtocol, subscriptionDetailsStorage: ObjectDetailsStorage) {
        setViewPickerData = SetViewData(
            document: document,
            subscriptionDetailsStorage: subscriptionDetailsStorage
        )
    }
    
    func setViewPicker(data: SetViewData) -> AnyView {
        setViewPickerCoordinatorAssembly.make(
            with: data.document,
            subscriptionDetailsStorage: data.subscriptionDetailsStorage
        )
    }
    
    // MARK: - EditorSetModuleOutput - SetViewSettings
    
    func showSetViewSettings(document: SetDocumentProtocol, subscriptionDetailsStorage: ObjectDetailsStorage) {
        setViewSettingsData = SetViewData(
            document: document,
            subscriptionDetailsStorage: subscriptionDetailsStorage
        )
    }
    
    func setViewSettings(data: SetViewData) -> AnyView {
        setViewSettingsCoordinatorAssembly.make(
            setDocument: data.document,
            viewId: data.document.activeView.id,
            mode: .edit,
            subscriptionDetailsStorage: data.subscriptionDetailsStorage
        )
    }
}

extension EditorSetCoordinatorViewModel {
    struct SetViewData: Identifiable {
        let id = UUID()
        let document: SetDocumentProtocol
        let subscriptionDetailsStorage: ObjectDetailsStorage
    }
}
