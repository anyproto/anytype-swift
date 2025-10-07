import Services
import Factory
import SwiftUI
import PhotosUI
import AsyncTools
import AnytypeCore

protocol SpaceFileUploadServiceProtocol: AnyObject, Sendable {
    var uploadStateStream: AnyAsyncSequence<UploadState> { get async }
    
    func uploadPhotoItems(_ items: [PhotosPickerItem], spaceId: String)
    func uploadImagePickerMedia(type: ImagePickerMediaType, spaceId: String)
    func uploadFiles(_ urls: [URL], spaceId: String)
    
    func cancelAllUploads()
}

final class SpaceFileUploadService: SpaceFileUploadServiceProtocol {

    private let fileActionsService: any FileActionsServiceProtocol = Container.shared.fileActionsService()
    private let activeTasks = SynchronizedDictionary<ActiveTaskIdentifier, Task<Void, Never>>()

    var uploadStateStream: AnyAsyncSequence<UploadState> {
        uploadStateStreamInternal.eraseToAnyAsyncSequence()
    }
    private let uploadStateStreamInternal = AsyncToManyStream<UploadState>()

    // MARK: - SpaceFileUploadServiceProtocol

    func uploadPhotoItems(_ items: [PhotosPickerItem], spaceId: String) {
        runUploadTask(spaceId: spaceId) {
            try await withThrowingTaskGroup(of: Void.self) { group in
                for item in items {
                    group.addTask {
                        let data = try await self.fileActionsService.createFileData(photoItem: item)
                        _ = try await self.fileActionsService.uploadFileObject(spaceId: spaceId, data: data, origin: .none)
                    }
                }
                try await group.waitForAll()
            }
        }
    }

    func uploadFiles(_ urls: [URL], spaceId: String) {
        runUploadTask(spaceId: spaceId) {
            try await withThrowingTaskGroup(of: Void.self) { group in
                for url in urls {
                    guard url.startAccessingSecurityScopedResource() else { return }
                    group.addTask {
                        let data = try self.fileActionsService.createFileData(fileUrl: url)
                        _ = try await self.fileActionsService.uploadFileObject(spaceId: spaceId, data: data, origin: .none)
                    }
                }
                try await group.waitForAll()
            }
        }
    }

    func uploadImagePickerMedia(type: ImagePickerMediaType, spaceId: String) {
        runUploadTask(spaceId: spaceId) { [weak self] in
            guard let self else { return }
            let data: FileData
            switch type {
            case .image(let image, let type):
                data = try fileActionsService.createFileData(image: image, type: type)
            case .video(let file):
                data = try fileActionsService.createFileData(fileUrl: file)
            }
            _ = try await fileActionsService.uploadFileObject(spaceId: spaceId, data: data, origin: .none)
        }
    }

    func cancelAllUploads() {
        for key in activeTasks.keys {
            activeTasks[key]?.cancel()
            activeTasks[key] = nil
            uploadStateStreamInternal.send(UploadState(spaceId: key.spaceId, isFinished: true, error: nil))
        }
    }

    // MARK: - Private

    private func runUploadTask(spaceId: String, work: @Sendable @escaping () async throws -> Void) {
        let taskId = UUID()

        let task = Task {
            do {
                uploadStateStreamInternal.send(UploadState(spaceId: spaceId, isFinished: false, error: nil))
                try await work()
                uploadStateStreamInternal.send(UploadState(spaceId: spaceId, isFinished: true, error: nil))
            } catch {
                uploadStateStreamInternal.send(UploadState(spaceId: spaceId, isFinished: true, error: error))
            }

            activeTasks.removeValue(forKey: ActiveTaskIdentifier(spaceId: spaceId, taskId: taskId))
        }

        activeTasks[ActiveTaskIdentifier(spaceId: spaceId, taskId: taskId)] = task
    }
}

struct UploadState: Sendable {
    let spaceId: String
    let isFinished: Bool
    let error: (any Error)?
}

struct ActiveTaskIdentifier: Hashable {
    let spaceId: String
    let taskId: UUID
}
