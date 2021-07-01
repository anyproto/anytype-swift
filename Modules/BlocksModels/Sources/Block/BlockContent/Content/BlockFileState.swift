public enum BlockFileState: Hashable {
    /// There is no file and preview, it's an empty block, that waits files.
    case empty
    /// There is still no file/preview, but file already uploading
    case uploading
    /// File exists, uploading is done
    case done
    /// Error while uploading
    case error
}
