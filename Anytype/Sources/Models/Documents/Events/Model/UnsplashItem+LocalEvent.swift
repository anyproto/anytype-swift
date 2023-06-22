import Services

extension UnsplashItem {
    var updateEvent: LocalEvent { .header(.coverUploading(.remotePreviewURL(url))) }
}
