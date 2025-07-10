import SwiftUI
import Services
import AnytypeCore
import DeepLinks

@MainActor
final class QRCodeScannerViewModifierModel: ObservableObject {
    @Published var showQrCodeScanner = false
    @Published var qrCode = ""
    @Published var qrCodeScanErrorText: String?
    @Published var qrCodeScanAlertError: QrCodeScanAlertError?
    @Published var openSettingsURL = false
    
    @Injected(\.cameraPermissionVerifier)
    private var cameraPermissionVerifier: any CameraPermissionVerifierProtocol
    @Injected(\.universalLinkParser)
    private var universalLinkParser: any UniversalLinkParserProtocol
    @Injected(\.appActionStorage)
    private var appActionStorage: AppActionStorage
    
    nonisolated init() { }
    
    func requestQrCodeScan() {
        Task { @MainActor in
            let isGranted = await cameraPermissionVerifier.cameraPermission.value
            if isGranted {
                showQrCodeScanner = true
            } else {
                openSettingsURL = true
            }
        }
    }
    
    func onQrCodeChange() {
        guard qrCode.isNotEmpty else { return }
        
        guard let url = URL(string: qrCode) else {
            qrCode = ""
            qrCodeScanAlertError = .notAnUrl
            return
        }
        
        guard let link = universalLinkParser.parse(url: url) else {
            qrCode = ""
            qrCodeScanAlertError = .invalidFormat
            return
        }
        
        guard case .invite = link else {
            qrCode = ""
            qrCodeScanAlertError = .wrongLinkType
            return
        }
        
        appActionStorage.action = .deepLink(link.toDeepLink(), .internal)
    }
    
    func onQrCodeScanErrorChange() {
        guard let qrCodeScanErrorText, qrCodeScanErrorText.isNotEmpty else { return }
        
        self.qrCodeScanErrorText = nil
        qrCodeScanAlertError = .custom(qrCodeScanErrorText)
    }
    
    func onQrScanTryAgain() {
        qrCodeScanAlertError = nil
        showQrCodeScanner = true
    }
    
    func onSettingsTap() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
}

struct QRCodeScannerViewModifier: ViewModifier {
    
    @StateObject private var model = QRCodeScannerViewModifierModel()
    @Binding private var shouldScan: Bool
    
    init(shouldScan: Binding<Bool>) {
        _shouldScan = shouldScan
    }
    
    func body(content: Content) -> some View {
        content
            .onChange(of: shouldScan) { newValue in
                if newValue {
                    model.requestQrCodeScan()
                    shouldScan = false
                }
            }
            .onChange(of: model.qrCode) { _ in
                model.onQrCodeChange()
            }
            .onChange(of: model.qrCodeScanErrorText) { _ in
                model.onQrCodeScanErrorChange()
            }
            .sheet(isPresented: $model.showQrCodeScanner) {
                QrCodeScannerView(qrCode: $model.qrCode, error: $model.qrCodeScanErrorText)
            }
            .anytypeSheet(item: $model.qrCodeScanAlertError) {
                QrCodeScanAlert(error: $0) {
                    model.onQrScanTryAgain()
                }
            }
            .alert(Loc.Auth.cameraPermissionTitle, isPresented: $model.openSettingsURL, actions: {
                Button(Loc.Alert.CameraPermissions.settings, role: .cancel, action: { model.onSettingsTap() })
                Button(Loc.cancel, action: {})
            }, message: {
                Text(verbatim: Loc.Alert.CameraPermissions.goToSettings)
            })
    }
}

extension View {
    func qrCodeScanner(shouldScan: Binding<Bool>) -> some View {
        modifier(QRCodeScannerViewModifier(shouldScan: shouldScan))
    }
}