import Foundation
import QRCode
import UIKit
import AnytypeCore
import DesignKit


@MainActor
final class ProfileQRCodeViewModel: ObservableObject {

    enum State {
        case loading
        case loaded(lightDocument: QRCode.Document, darkDocument: QRCode.Document, URL)
        case error
    }

    // MARK: - DI

    @Injected(\.accountManager)
    private var accountManager: any AccountManagerProtocol
    @Injected(\.universalLinkParser)
    private var universalLinkParser: any UniversalLinkParserProtocol

    // MARK: - State

    @Published private(set) var state: State = .loading
    @Published var sharedUrl: URLIdentifiable?
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

        configureDocument(lightDoc, foregroundColor: UIColor.black.cgColor)
        configureDocument(darkDoc, foregroundColor: UIColor.white.cgColor)

        state = .loaded(lightDocument: lightDoc, darkDocument: darkDoc, url)
    }

    private func configureDocument(_ doc: QRCode.Document, foregroundColor: CGColor) {
        let design = QRCode.Design()
        design.shape.onPixels = QRCode.PixelShape.Circle()
        design.shape.eye = QRCode.EyeShape.Cloud()
        design.backgroundColor(UIColor.clear.cgColor)
        design.style.onPixels = QRCode.FillStyle.Solid(foregroundColor)
        doc.design = design

        if let icon = UIImage(asset: .QrCode.smile)?.cgImage {
            let logoTemplate = QRCode.LogoTemplate(
                image: icon,
                path: CGPath(rect: CGRect(x: 0.33, y: 0.33, width: 0.34, height: 0.34), transform: nil),
                inset: 4
            )
            doc.logoTemplate = logoTemplate
        }
    }
}
