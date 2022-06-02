import BlocksModels

extension BlockFile {
    var mediaData: BlockFileMediaData {
        BlockFileMediaData(
            size: FileSizeConverter.convert(size: Int(metadata.size)),
            name: metadata.name,
            iconImageName: BlockFileIconBuilder.convert(mime: metadata.mime, fileName: metadata.name)
        )
    }
}
