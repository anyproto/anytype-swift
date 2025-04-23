import UIKit
import SwiftEntryKit
import Combine
import Services

@MainActor
protocol ToastPresenterProtocol: AnyObject {
    func show(message: String)
    func show(message: NSAttributedString)
    
    func showSuccessAlert(message: String)
    func showFailureAlert(message: String)
    
    func dismiss(completion: @escaping () -> Void)
    
    func showObjectName(
        _ firstObjectName: String,
        middleAction: String,
        secondObjectId: String,
        spaceId: String,
        tapHandler: @escaping () -> Void
    )
    func showObjectCompositeAlert(
        prefixText: String,
        objectId: String,
        spaceId: String,
        tapHandler: @escaping () -> Void
    )
}

final class ToastPresenter: ToastPresenterProtocol {
    static var shared: ToastPresenter? // Used only for SwiftUI

    @Injected(\.documentsProvider)
    private var documentsProvider: any DocumentsProviderProtocol
    
    nonisolated init() {}
    
    // MARK: - ToastPresenterProtocol
    
    func showSuccessAlert(message: String) {
        DesignKit.ToastPresenter.showSuccessAlert(message: message)
    }
    
    func showFailureAlert(message: String) {
        DesignKit.ToastPresenter.showFailureAlert(message: message)
    }
    
    func show(message: String) {
        DesignKit.ToastPresenter.show(message: message)
    }
    
    func show(message: NSAttributedString) {
        DesignKit.ToastPresenter.show(message: message)
    }
    
    func dismiss(completion: @escaping () -> Void) {
        DesignKit.ToastPresenter.dismiss(completion: completion)
    }
    
    func showObjectName(
        _ firstObjectName: String,
        middleAction: String,
        secondObjectId: String,
        spaceId: String,
        tapHandler: @escaping () -> Void
    ) {
        let objectAttributedString = NSMutableAttributedString(
            string: firstObjectName.trimmed(numberOfCharacters: Constants.numberOfTitleCharacters),
            attributes: ToastAttributes.objectAttributes
        )
        objectAttributedString.append(.init(string: " "))
        objectAttributedString.append(.init(string: middleAction, attributes: ToastAttributes.defaultAttributes))
        
        showObjectCompositeAlert(
            p1: objectAttributedString,
            objectId: secondObjectId,
            spaceId: spaceId,
            tapHandler: tapHandler
        )
    }
    
    func showObjectCompositeAlert(
        prefixText: String,
        objectId: String,
        spaceId: String,
        tapHandler: @escaping () -> Void
    ) {
        showObjectCompositeAlert(
            p1: .init(string: prefixText, attributes: ToastAttributes.defaultAttributes),
            objectId: objectId,
            spaceId: spaceId,
            tapHandler: tapHandler
        )
    }
    
    private func showObjectCompositeAlert(
        p1: NSAttributedString,
        objectId: String,
        spaceId: String,
        tapHandler: @escaping () -> Void
    ) {
        Task { @MainActor in
            guard let details = await retrieveObjectDetails(objectId: objectId, spaceId: spaceId) else {
                return
            }
            
            let compositeAttributedString = NSMutableAttributedString()
            let iconObjectAttributedString = createAttributedString(from: details)
            
            compositeAttributedString.append(iconObjectAttributedString)
            
            let attributedString = NSMutableAttributedString(attributedString: p1)
            attributedString.append(.init(string: "  "))
            
            let tappableAttributedString = NSMutableAttributedString(attributedString: iconObjectAttributedString)
            
            let dismissableTapHandler: () -> Void = { [weak self] in
                self?.dismiss { tapHandler() }
            }
            
            tappableAttributedString.addAttributes([.tapHandler: dismissableTapHandler], range: tappableAttributedString.wholeRange)
            
            attributedString.append(tappableAttributedString)
            
            show(message: attributedString)
        }
    }
    
    private func createAttributedString(from objectDetails: ObjectDetails) -> NSAttributedString {
        return NSAttributedString(
            string: objectDetails.title.trimmed(numberOfCharacters: Constants.numberOfTitleCharacters),
            attributes: ToastAttributes.objectAttributes
        )
    }
    
    private func retrieveObjectDetails(objectId: String, spaceId: String) async -> ObjectDetails? {
        let targetDocument = documentsProvider.document(objectId: objectId, spaceId: spaceId, mode: .preview)
        try? await targetDocument.open()
        
        return targetDocument.details
    }
}

extension ToastPresenter {
    enum Constants {
        static let numberOfTitleCharacters: Int = 10
    }
}

extension ToastAttributes {
    static var objectAttributes: [NSAttributedString.Key : Any] {
        [.foregroundColor: UIColor.Text.white, .font: AnytypeFont.caption1Medium.uiKitFont]
    }
}
