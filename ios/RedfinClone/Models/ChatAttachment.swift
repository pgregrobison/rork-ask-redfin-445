import Foundation

nonisolated enum ChatAttachmentKind: String, Codable, Sendable {
    case photo
    case video
}

nonisolated struct ChatAttachment: Identifiable, Codable, Sendable, Hashable {
    let id: String
    let kind: ChatAttachmentKind
    /// Filename within the app's caches directory.
    let fileName: String
    /// Optional thumbnail filename for videos (also in caches dir).
    let thumbnailFileName: String?

    init(
        id: String = UUID().uuidString,
        kind: ChatAttachmentKind,
        fileName: String,
        thumbnailFileName: String? = nil
    ) {
        self.id = id
        self.kind = kind
        self.fileName = fileName
        self.thumbnailFileName = thumbnailFileName
    }

    var fileURL: URL {
        AttachmentStore.cachesDir.appendingPathComponent(fileName)
    }

    var thumbnailURL: URL? {
        guard let thumb = thumbnailFileName else { return nil }
        return AttachmentStore.cachesDir.appendingPathComponent(thumb)
    }
}
