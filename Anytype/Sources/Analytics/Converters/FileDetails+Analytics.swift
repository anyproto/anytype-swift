import Services

extension FileDetails {
    var analyticsType: AnalyticsObjectType {
        .file(ext: fileExt)
    }
}
