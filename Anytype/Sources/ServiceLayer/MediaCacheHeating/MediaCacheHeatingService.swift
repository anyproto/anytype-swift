import Services

protocol MediaCacheHeatingServiceProtocol: AnyObject, Sendable {
    func updateVisibleMedia(attachmentDetails: [ObjectDetails]) async
    func cancelAll() async
}

actor MediaCacheHeatingService: MediaCacheHeatingServiceProtocol {
    @Injected(\.fileService)
    private var fileService: any FileServiceProtocol

    private var scheduledDownloads = Set<String>()

    func updateVisibleMedia(attachmentDetails: [ObjectDetails]) async {
        let imageIds = attachmentDetails
            .filter { $0.resolvedLayoutValue == .image }
            .map(\.id)
        let currentImageIds = Set(imageIds)

        let toSchedule = currentImageIds.subtracting(scheduledDownloads)
        for fileId in toSchedule {
            do {
                try await fileService.scheduleCacheDownload(fileObjectId: fileId)
                scheduledDownloads.insert(fileId)
            } catch {}
        }

        let toCancel = scheduledDownloads.subtracting(currentImageIds)
        for fileId in toCancel {
            try? await fileService.cancelCacheDownload(fileObjectId: fileId)
            scheduledDownloads.remove(fileId)
        }
    }

    func cancelAll() async {
        for fileId in scheduledDownloads {
            try? await fileService.cancelCacheDownload(fileObjectId: fileId)
        }
        scheduledDownloads.removeAll()
    }
}
