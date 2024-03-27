import Services

extension FileDetails {
    var analyticsType: AnalyticsObjectType {
        .file(fileExt: fileExt)
    }
}
