import Foundation
import QRCode
import UIKit
import DeepLinks
import AnytypeCore
import DesignKit


@MainActor
final class ProfileQRCodeViewModel: ObservableObject {

    enum State {
        case loading
        case loaded(QRCode.Document)
        case error
    }

    // MARK: - DI

    @Injected(\.accountManager)
    private var accountManager: any AccountManagerProtocol
    @Injected(\.deepLinkParser)
    private var deepLinkParser: any DeepLinkParserProtocol
    
    // MARK: - State

    @Published private(set) var state: State = .loading
    @Published var sharedData: DataIdentifiable?
    @Published var toastBarData: ToastBarData?

    let anyName: String
    let profileIcon: Icon

    // MARK: - Lifecycle

    init() {
        self.profileIcon = Container.shared.profileStorage().profile.icon
        anyName = Container.shared.membershipStatusStorage().currentStatus.anyName.formatted
    }

    // MARK: - Public

    func onAppear() {
        createQR()
        AnytypeAnalytics.instance().logScreenQr(type: .profile, route: .settings)
    }

    func onShare() {
        guard case .loaded(let document) = state else { return }
        sharedData = document.jpegData(dimension: 600)?.identifiable
    }

    func onDownload() {
        guard case .loaded(let document) = state,
              let imageData = document.jpegData(dimension: 600),
              let image = UIImage(data: imageData) else { return }
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        toastBarData = ToastBarData(Loc.savedToPhotos)
    }

    // MARK: - Private

    private func createQR() {
        guard let url = deepLinkParser.createUrl(deepLink: .hi(
            identity: accountManager.account.id,
            key: "placeholder_key"
        ), scheme: .buildSpecific) else {
            state = .error
            anytypeAssertionFailure("Can not build qr code", info: [
                "identity": accountManager.account.id,
                "key": "placeholder_key"
            ])
            return
        }

        let doc = QRCode.Document(generator: QRCodeGenerator_External())
        doc.utf8String = url.absoluteString
        doc.design.backgroundColor(UIColor.white.cgColor)

        if let icon = UIImage(asset: .QrCode.smile)?.cgImage {
            let logoTemplate = QRCode.LogoTemplate(
                image: icon,
                path: CGPath(rect: CGRect(x: 0.33, y: 0.33, width: 0.34, height: 0.34), transform: nil),
                inset: 4
            )
            doc.logoTemplate = logoTemplate
        }

        state = .loaded(doc)
    }
}
