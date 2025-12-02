import Foundation
import QRCode
import UIKit
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
    @Injected(\.universalLinkParser)
    private var universalLinkParser: any UniversalLinkParserProtocol

    // MARK: - State

    @Published private(set) var state: State = .loading
    @Published var sharedData: DataIdentifiable?
    @Published var toastBarData: ToastBarData?
    @Published var shouldScanQrCode = false

    let anyName: String
    let profileIcon: Icon

    // MARK: - Lifecycle

    init() {
        self.profileIcon = Container.shared.profileStorage().profile.icon
        anyName = Container.shared.membershipStatusStorage().currentStatus.anyName.formatted
    }

    // MARK: - Public

    func onAppear() {
        AnytypeAnalytics.instance().logScreenQr(type: .profile, route: .settings)
        createQR()
    }

    func onShare() {
        guard case .loaded(let document) = state else { return }
        sharedData = try? document.jpegData(dimension: 600).identifiable
    }

    func onDownload() {
        guard case .loaded(let document) = state,
              let imageData = try? document.jpegData(dimension: 600),
              let image = UIImage(data: imageData) else { return }
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        toastBarData = ToastBarData(Loc.savedToPhotos)
    }

    func onScanTap() {
        shouldScanQrCode = true
    }

    // MARK: - Private

    private func createQR() {
        let metadataKey = accountManager.account.info.metadataKey
        guard let url = universalLinkParser.createUrl(link: .hi(
            identity: accountManager.account.id,
            key: metadataKey
        )) else {
            state = .error
            anytypeAssertionFailure("Can not build universal link for qr code", info: ["identity": accountManager.account.id, "key": metadataKey])
            return
        }

        guard let doc = try? QRCode.Document(utf8String: url.absoluteString) else {
            state = .error
            anytypeAssertionFailure("Can not build qr code", info: ["url": url.absoluteString])
            return
        }        
        
        let design = QRCode.Design()
        design.shape.onPixels = QRCode.PixelShape.Circle()
        design.shape.eye = QRCode.EyeShape.Cloud()
        design.backgroundColor(UIColor.clear.cgColor)
        doc.design = design

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
