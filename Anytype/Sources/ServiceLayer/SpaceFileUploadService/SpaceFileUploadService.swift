import Services
import Factory
import SwiftUI
import PhotosUI
import AsyncTools
import AnytypeCore

protocol SpaceFileUploadServiceProtocol: AnyObject, Sendable {
    var uploadStateStream: AnyAsyncSequence<UploadState> { get async }
    
    func uploadPhotoItems(_ items: [PhotosPickerItem], spaceId: String) async
    func uploadImagePickerMedia(type: ImagePickerMediaType, spaceId: String) async
    func uploadFiles(_ urls: [URL], spaceId: String) async
    
    func cancelAllUploads() async
}

actor SpaceFileUploadService: SpaceFileUploadServiceProtocol {

    private let fileActionsService: any FileActionsServiceProtocol = Container.shared.fileActionsService()

    private var activeTasks: [ActiveTaskIdentifier: Task<Void, Never>] = [:]

    // MARK: - Stream

    var uploadStateStream: AnyAsyncSequence<UploadState> {
        uploadStateStreamInternal.eraseToAnyAsyncSequence()
    }
    private let uploadStateStreamInternal = AsyncToManyStream<UploadState>()

    // MARK: - SpaceFileUploadServiceProtocol
    
    func uploadPhotoItems(_ items: [PhotosPickerItem], spaceId: String) async {

        let taskId = UUID()
        
        let task = Task {
            do {
                // notify about start
                uploadStateStreamInternal.send(UploadState(spaceId: spaceId, isFinished: false, error: nil))

                try await withThrowingTaskGroup(of: Void.self) { group in
                    for item in items {
                        group.addTask {
                            let data = try await self.fileActionsService.createFileData(photoItem: item)
                            _ = try await self.fileActionsService.uploadFileObject(
                                spaceId: spaceId,
                                data: data,
                                origin: .none
                            )
                        }
                    }
                    try await group.waitForAll()
                }

                // finished successfully
                uploadStateStreamInternal.send(UploadState(spaceId: spaceId, isFinished: true, error: nil))
            } catch {
                // finished with error
                uploadStateStreamInternal.send(UploadState(spaceId: spaceId, isFinished: true, error: error))
            }

            activeTasks.removeValue(forKey: ActiveTaskIdentifier(spaceId: spaceId, taskId: taskId))
        }

        activeTasks[ActiveTaskIdentifier(spaceId: spaceId, taskId: taskId)] = task
    }
    
    func uploadFiles(_ urls: [URL], spaceId: String) async {

        let taskId = UUID()
        
        let task = Task {
            do {
                // notify about start
                uploadStateStreamInternal.send(UploadState(spaceId: spaceId, isFinished: false, error: nil))

                try await withThrowingTaskGroup(of: Void.self) { group in
                    for url in urls {
                        group.addTask {
                            let gotAccess = url.startAccessingSecurityScopedResource()
                            guard gotAccess else { return }
                            
                            let data = try self.fileActionsService.createFileData(fileUrl: url)
                            _ = try await self.fileActionsService.uploadFileObject(
                                spaceId: spaceId,
                                data: data,
                                origin: .none
                            )
                        }
                    }
                    try await group.waitForAll()
                }

                // finished successfully
                uploadStateStreamInternal.send(UploadState(spaceId: spaceId, isFinished: true, error: nil))
            } catch {
                // finished with error
                uploadStateStreamInternal.send(UploadState(spaceId: spaceId, isFinished: true, error: error))
            }

            activeTasks.removeValue(forKey: ActiveTaskIdentifier(spaceId: spaceId, taskId: taskId))
        }

        activeTasks[ActiveTaskIdentifier(spaceId: spaceId, taskId: taskId)] = task
    }
    
    func uploadImagePickerMedia(type: ImagePickerMediaType, spaceId: String) async {
        let taskId = UUID()
        
        let task = Task {
            do {
                // notify about start
                uploadStateStreamInternal.send(UploadState(spaceId: spaceId, isFinished: false, error: nil))
                
                let data: FileData
                switch type {
                case .image(let image, let type):
                    data = try fileActionsService.createFileData(image: image, type: type)
                case .video(let file):
                    data = try fileActionsService.createFileData(fileUrl: file)
                }

                _ = try await self.fileActionsService.uploadFileObject(
                    spaceId: spaceId,
                    data: data,
                    origin: .none
                )
                
                // finished successfully
                uploadStateStreamInternal.send(UploadState(spaceId: spaceId, isFinished: true, error: nil))
            } catch {
                // finished with error
                uploadStateStreamInternal.send(UploadState(spaceId: spaceId, isFinished: true, error: error))
            }

            activeTasks.removeValue(forKey: ActiveTaskIdentifier(spaceId: spaceId, taskId: taskId))
        }

        activeTasks[ActiveTaskIdentifier(spaceId: spaceId, taskId: taskId)] = task
    }

    func cancelAllUploads() async {
        for (id, task) in activeTasks {
            task.cancel()
            activeTasks[id] = nil
            uploadStateStreamInternal.send(UploadState(spaceId: id.spaceId, isFinished: true, error: nil))
        }
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
