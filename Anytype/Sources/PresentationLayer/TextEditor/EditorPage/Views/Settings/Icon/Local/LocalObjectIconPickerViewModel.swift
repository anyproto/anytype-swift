import UIKit
import Services
import AnytypeCore

@MainActor
protocol LocalObjectIconPickerOutput: AnyObject {
    func localFileDataDidChanged(_ data: FileData?)
}

@MainActor
@Observable
final class LocalObjectIconPickerViewModel {

    // MARK: - Private variables

    @ObservationIgnored @Injected(\.fileActionsService)
    private var fileService: any FileActionsServiceProtocol

    private(set) var itemProvider: NSItemProvider? = nil
    private(set) var isRemoveEnabled: Bool = false
    @ObservationIgnored
    private var fileData: FileData?

    @ObservationIgnored
    private weak var output: (any LocalObjectIconPickerOutput)?
    
    init(data: LocalObjectIconPickerData) {
        self.fileData = data.fileData
        self.isRemoveEnabled = fileData.isNotNil
        self.output = data.output
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
