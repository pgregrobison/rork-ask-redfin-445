import Foundation
import UIKit
import AVFoundation

enum AttachmentStore {
    static var cachesDir: URL {
        let base = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        let dir = base.appendingPathComponent("ChatAttachments", isDirectory: true)
        if !FileManager.default.fileExists(atPath: dir.path) {
            try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        }
        return dir
    }

    @discardableResult
    static func saveImage(_ image: UIImage) -> ChatAttachment? {
        guard let data = image.jpegData(compressionQuality: 0.85) else { return nil }
        let name = "img_\(UUID().uuidString).jpg"
        let url = cachesDir.appendingPathComponent(name)
        do {
            try data.write(to: url, options: .atomic)
            return ChatAttachment(kind: .photo, fileName: name)
        } catch {
            return nil
        }
    }

    @discardableResult
    static func saveImageData(_ data: Data) -> ChatAttachment? {
        let name = "img_\(UUID().uuidString).jpg"
        let url = cachesDir.appendingPathComponent(name)
        do {
            try data.write(to: url, options: .atomic)
            return ChatAttachment(kind: .photo, fileName: name)
        } catch {
            return nil
        }
    }

    @discardableResult
    static func saveVideo(at sourceURL: URL) -> ChatAttachment? {
        let ext = sourceURL.pathExtension.isEmpty ? "mov" : sourceURL.pathExtension
        let name = "vid_\(UUID().uuidString).\(ext)"
        let dest = cachesDir.appendingPathComponent(name)
        do {
            if FileManager.default.fileExists(atPath: dest.path) {
                try FileManager.default.removeItem(at: dest)
            }
            try FileManager.default.copyItem(at: sourceURL, to: dest)
        } catch {
            return nil
        }

        let thumbName = generateThumbnail(for: dest)
        return ChatAttachment(kind: .video, fileName: name, thumbnailFileName: thumbName)
    }

    @discardableResult
    static func saveVideoData(_ data: Data, fileExtension: String = "mov") -> ChatAttachment? {
        let name = "vid_\(UUID().uuidString).\(fileExtension)"
        let dest = cachesDir.appendingPathComponent(name)
        do {
            try data.write(to: dest, options: .atomic)
        } catch {
            return nil
        }
        let thumbName = generateThumbnail(for: dest)
        return ChatAttachment(kind: .video, fileName: name, thumbnailFileName: thumbName)
    }

    private static func generateThumbnail(for videoURL: URL) -> String? {
        let asset = AVURLAsset(url: videoURL)
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true
        let time = CMTime(seconds: 0.1, preferredTimescale: 600)
        guard let cgImage = try? generator.copyCGImage(at: time, actualTime: nil) else {
            return nil
        }
        let image = UIImage(cgImage: cgImage)
        guard let data = image.jpegData(compressionQuality: 0.8) else { return nil }
        let name = "thumb_\(UUID().uuidString).jpg"
        let url = cachesDir.appendingPathComponent(name)
        try? data.write(to: url, options: .atomic)
        return name
    }
}
