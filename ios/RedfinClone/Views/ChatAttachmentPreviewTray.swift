import SwiftUI

struct ChatAttachmentPreviewTray: View {
    let attachments: [ChatAttachment]
    let onRemove: (ChatAttachment) -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(attachments) { att in
                    ChatAttachmentPreviewThumb(attachment: att, onRemove: { onRemove(att) })
                        .transition(.scale(scale: 0.5).combined(with: .opacity))
                }
            }
            .padding(.horizontal, Theme.Spacing.md)
            .padding(.vertical, 8)
        }
    }
}

private struct ChatAttachmentPreviewThumb: View {
    let attachment: ChatAttachment
    let onRemove: () -> Void

    var body: some View {
        let thumbURL = attachment.kind == .video ? attachment.thumbnailURL : attachment.fileURL
        ZStack(alignment: .topTrailing) {
            Group {
                if let url = thumbURL,
                   let data = try? Data(contentsOf: url),
                   let img = UIImage(data: data) {
                    Image(uiImage: img)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } else {
                    Color(.secondarySystemBackground)
                }
            }
            .frame(width: 64, height: 64)
            .clipShape(.rect(cornerRadius: 12, style: .continuous))
            .overlay {
                if attachment.kind == .video {
                    Image(systemName: "play.fill")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(.white)
                        .padding(6)
                        .background(.black.opacity(0.45), in: Circle())
                }
            }
            .shadow(color: .black.opacity(0.08), radius: 3, x: 0, y: 1)

            Button(action: onRemove) {
                Image(systemName: "xmark")
                    .font(.system(size: 9, weight: .heavy))
                    .foregroundStyle(.white)
                    .frame(width: 20, height: 20)
                    .background(Color.black.opacity(0.75), in: Circle())
                    .overlay(Circle().stroke(.white, lineWidth: 1.5))
            }
            .offset(x: 6, y: -6)
        }
        .padding(.top, 6)
        .padding(.trailing, 6)
    }
}
