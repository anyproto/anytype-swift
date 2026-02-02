import Foundation
import QRCode
import UIKit
import AnytypeCore
import Assets
import DesignKit

@MainActor
@Observable
final class ProfileQRCodeViewModel {

    enum State {
        case loading
        case loaded(lightDocument: QRCode.Document, darkDocument: QRCode.Document, URL)
        case error
    }

    // MARK: - DI

    @ObservationIgnored @Injected(\.accountManager)
    private var accountManager: any AccountManagerProtocol
    @ObservationIgnored @Injected(\.universalLinkParser)
    private var universalLinkParser: any UniversalLinkParserProtocol

    // MARK: - State

    private(set) var state: State = .loading
    var sharedUrl: URLIdentifiable?
    var toastBarData: ToastBarData?
    var shouldScanQrCode = false

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

    func onCopyLink() {
        guard case .loaded(_, _, let url) = state else { return }
        UIPasteboard.general.string = url.absoluteString
        toastBarData = ToastBarData(Loc.copied)
    }

    func onShare() {
        guard case .loaded(_, _, let url) = state else { return }
        sharedUrl = url.identifiable
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

        guard let lightDoc = try? QRCode.Document(utf8String: url.absoluteString),
              let darkDoc = try? QRCode.Document(utf8String: url.absoluteString) else {
            state = .error
            anytypeAssertionFailure("Can not build qr code", info: ["url": url.absoluteString])
            return
        }

        configureDocument(lightDoc, foregroundColor: UIColor.black.cgColor, smileAsset: .QrCode.smile)
        configureDocument(darkDoc, foregroundColor: UIColor.white.cgColor, smileAsset: .QrCode.smileLight)

        state = .loaded(lightDocument: lightDoc, darkDocument: darkDoc, url)
    }

    private func configureDocument(_ doc: QRCode.Document, foregroundColor: CGColor, smileAsset: ImageAsset) {
        let design = QRCode.Design()
        design.shape.onPixels = QRCode.PixelShape.Circle()
        design.shape.eye = QRCode.EyeShape.Cloud()
        design.backgroundColor(UIColor.clear.cgColor)
        design.style.onPixels = QRCode.FillStyle.Solid(foregroundColor)
        doc.design = design

        if let icon = UIImage(asset: smileAsset)?.cgImage {
            let logoTemplate = QRCode.LogoTemplate(
                image: icon,
                path: CGPath(rect: CGRect(x: 0.33, y: 0.33, width: 0.34, height: 0.34), transform: nil),
                inset: 4
            )
            doc.logoTemplate = logoTemplate
        }
    }
}
