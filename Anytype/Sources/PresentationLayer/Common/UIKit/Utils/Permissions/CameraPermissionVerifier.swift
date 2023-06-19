import AVFoundation
import AnytypeCore
import Combine

final class CameraPermissionVerifier {
    var cameraPermission: Future<Bool, Never> {
        Future<Bool, Never> { promise in
            switch AVCaptureDevice.authorizationStatus(for: .video) {
            case .denied, .restricted:
                promise(.success(false))
            case .authorized:
                promise(.success(true))
            case .notDetermined:
                AVCaptureDevice.requestAccess(for: .video) { success in
                    promise(.success(success))
                }
            @unknown default:
                anytypeAssertionFailure("@unknown AVAuthorizationStatus case")
                promise(.success(false))
            }
        }
    }
}
