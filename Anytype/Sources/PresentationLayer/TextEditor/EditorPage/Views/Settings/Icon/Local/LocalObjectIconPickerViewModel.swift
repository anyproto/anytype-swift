import Combine
import UIKit
import Services
import AnytypeCore

@MainActor
protocol LocalObjectIconPickerOutput: AnyObject {
    func localFileDataDidChanged(_ data: FileData?)
}

@MainActor
final class LocalObjectIconPickerViewModel: ObservableObject {

    // MARK: - Private variables

    @Injected(\.fileActionsService)
    private var fileService: any FileActionsServiceProtocol
    
    @Published private(set) var itemProvider: NSItemProvider? = nil
    @Published private(set) var isRemoveEnabled: Bool = false
    private var fileData: FileData?

    private weak var output: (any LocalObjectIconPickerOutput)?
    
    init(fileData: FileData?, output: (any LocalObjectIconPickerOutput)?) {
        self.fileData = fileData
        self.isRemoveEnabled = fileData.isNotNil
        self.output = output
    }
    
    func onSelectItemProvider(_ itemProvider: NSItemProvider) {
        self.itemProvider = itemProvider
    }
    
    func itemProviderUpdated(_ itemProvider: SafeNSItemProvider) async {
        fileData = try? await fileService.createFileData(source: .itemProvider(itemProvider.value))
        fileDataDidChanged()
    }
    
    func removeIcon() {
        fileData = nil
        fileDataDidChanged()
    }
    
    private func fileDataDidChanged() {
        isRemoveEnabled = fileData.isNotNil
        output?.localFileDataDidChanged(fileData)
    }
}
