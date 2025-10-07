@preconcurrency import AVFoundation
import UIKit
import SwiftUI

struct QrCodeScannerData: Identifiable {
    var entropy: Binding<String>
    var error: Binding<String?>
    
    let id = UUID()
}

// MARK: - SwiftUI adapter

struct QrCodeScannerView: UIViewControllerRepresentable {
    @Binding var qrCode: String
    @Binding var error: String?
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(qrCode: $qrCode, error: $error)
    }

    func makeUIViewController(context: UIViewControllerRepresentableContext<QrCodeScannerView>) -> ScannerViewController {
        let scanner = ScannerViewController()
        scanner.delegate = context.coordinator
        return scanner
    }

    func updateUIViewController(_ uiViewController: ScannerViewController,
                                context: UIViewControllerRepresentableContext<QrCodeScannerView>) {

    }
    
    // MARK: - Coordinator
    
    class Coordinator: NSObject, ScannerViewControllerDeleage {
        @Binding var qrCode: String
        @Binding var error: String?

        init(qrCode: Binding<String>, error: Binding<String?>) {
            _qrCode = qrCode
            _error = error
        }
        
        func scanningComplete(result: Result<String, ScannerError>) {
            switch result {
            case .failure(let error):
                self.error = error.localizedDescription
            case .success(let qrCode):
                self.qrCode = qrCode
            }
        }
    }
}


// MARK: - QR code view controller delegate

enum ScannerError: Error {
    case scanningNotSupported
}

extension ScannerError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .scanningNotSupported:
            return Loc.Scanner.Error.scanningNotSupported
        }
    }
}

protocol ScannerViewControllerDeleage {
    
    func scanningComplete(result: Result<String, ScannerError>)
}


// MARK: - QR code view controller

class ScannerViewController: UIViewController, @preconcurrency AVCaptureMetadataOutputObjectsDelegate {
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    var delegate: (any ScannerViewControllerDeleage)?
    
    private let serialQueue = DispatchQueue(label: "ScannerViewController.serial.queue")
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .Background.primary
        captureSession = AVCaptureSession()

        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
        let videoInput: AVCaptureDeviceInput

        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return
        }

        if (captureSession.canAddInput(videoInput)) {
            captureSession.addInput(videoInput)
        } else {
            failed()
            return
        }

        let metadataOutput = AVCaptureMetadataOutput()

        if (captureSession.canAddOutput(metadataOutput)) {
            captureSession.addOutput(metadataOutput)

            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
        } else {
            failed()
            return
        }

        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)

        startRunningCaptureSession()
    }

    func failed() {
        delegate?.scanningComplete(result: .failure(.scanningNotSupported))
        captureSession = nil
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        startRunningCaptureSession()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        stopRunningCaptureSession()
    }
    
    // MARK: AVCaptureMetadataOutputObjectsDelegate
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        MainActor.assumeIsolated {
            stopRunningCaptureSession()
            
            if let metadataObject = metadataObjects.first {
                guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
                guard let stringValue = readableObject.stringValue else { return }
                AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
                found(code: stringValue)
            }
            
            dismiss(animated: true)
        }
    }

    func found(code: String) {
        delegate?.scanningComplete(result: .success(code))
    }
    
    private func startRunningCaptureSession() {
        serialQueue.async { [captureSession] in
            guard let captureSession else { return }
            if !captureSession.isRunning {
                captureSession.startRunning()
            }
        }
    }
    
    private func startRunningCaptureSessionIfNeeded() {
        if !captureSession.isRunning {
            captureSession.startRunning()
        }
    }
    
    private func stopRunningCaptureSession() {
        serialQueue.async { [captureSession] in
            guard let captureSession else { return }
            if captureSession.isRunning {
                captureSession.stopRunning()
            }
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
}
