//
//  ScannerViewController.swift
//  AnyType
//
//  Created by Denis Batvinkin on 10.12.2019.
//  Copyright © 2019 AnyType. All rights reserved.
//

import AVFoundation
import UIKit
import SwiftUI


// MARK: - SwiftUI adapter

struct QRCodeScannerView: UIViewControllerRepresentable {
    @Environment(\.presentationMode) var presentationMode
    @Binding var qrCode: String
    @Binding var error: String?
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(presentationMode: presentationMode, qrCode: $qrCode, error: $error)
    }

    func makeUIViewController(context: UIViewControllerRepresentableContext<QRCodeScannerView>) -> ScannerViewController {
        let scanner = ScannerViewController()
        scanner.delegate = context.coordinator
        return scanner
    }

    func updateUIViewController(_ uiViewController: ScannerViewController,
                                context: UIViewControllerRepresentableContext<QRCodeScannerView>) {

    }
    
    // MARK: - Coordinator
    
    class Coordinator: NSObject, UINavigationControllerDelegate, ScannerViewControllerDeleage {
        @Binding var presentationMode: PresentationMode
        @Binding var qrCode: String
        @Binding var error: String?

        init(presentationMode: Binding<PresentationMode>, qrCode: Binding<String>, error: Binding<String?>) {
            _presentationMode = presentationMode
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
            presentationMode.dismiss()
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
            return NSLocalizedString("Scanning not supported", comment: "Your device does not support scanning a code from an item. Please use a device with a camera.")
        }
    }
}

protocol ScannerViewControllerDeleage {
    
    func scanningComplete(result: Result<String, ScannerError>)
}


// MARK: - QR code view controller

class ScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    var delegate: ScannerViewControllerDeleage?
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.backgroundSecondary
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

        captureSession.startRunning()
    }

    func failed() {
        delegate?.scanningComplete(result: .failure(.scanningNotSupported))
        captureSession = nil
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if (captureSession?.isRunning == false) {
            captureSession.startRunning()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if (captureSession?.isRunning == true) {
            captureSession.stopRunning()
        }
    }
    
    // MARK: AVCaptureMetadataOutputObjectsDelegate
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        captureSession.stopRunning()

        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            found(code: stringValue)
        }

        dismiss(animated: true)
    }

    func found(code: String) {
        delegate?.scanningComplete(result: .success(code))
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
}
