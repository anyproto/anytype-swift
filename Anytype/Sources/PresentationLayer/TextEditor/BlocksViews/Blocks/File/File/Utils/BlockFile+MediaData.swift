import BlocksModels

extension BlockFile {
    var mediaData: BlockFileMediaData {
        BlockFileMediaData(
            size: FileSizeConverter.convert(size: metadata.size),
            name: metadata.name,
            iconImageName: FileIconBuilder.convert(mime: metadata.mime, fileName: metadata.name)
        )
    }
}
