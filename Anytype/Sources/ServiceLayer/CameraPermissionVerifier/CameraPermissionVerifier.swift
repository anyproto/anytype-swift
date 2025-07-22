import AVFoundation
import AnytypeCore
import Combine

protocol CameraPermissionVerifierProtocol: Sendable {
    func cameraIsGranted() async -> Bool
}

final class CameraPermissionVerifier: CameraPermissionVerifierProtocol {
    func cameraIsGranted() async -> Bool {
        await withCheckedContinuation { continuation in
            switch AVCaptureDevice.authorizationStatus(for: .video) {
            case .denied, .restricted:
                continuation.resume(returning: false)
            case .authorized:
                continuation.resume(returning: true)
            case .notDetermined:
                AVCaptureDevice.requestAccess(for: .video) { success in
                    continuation.resume(returning: success)
                }
            @unknown default:
                anytypeAssertionFailure("@unknown AVAuthorizationStatus case")
                continuation.resume(returning: false)
            }
        }
    }
}
