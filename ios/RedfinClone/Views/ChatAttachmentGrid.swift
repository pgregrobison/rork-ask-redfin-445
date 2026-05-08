import SwiftUI
import AVKit

struct ChatAttachmentGrid: View {
    let attachments: [ChatAttachment]
    @State private var playingAttachmentId: String?

    var body: some View {
        let radius = Theme.Radius.chatBubble
        VStack(alignment: .trailing, spacing: 4) {
            switch attachments.count {
            case 0:
                EmptyView()
            case 1:
                tile(attachments[0], height: 220)
                    .clipShape(.rect(cornerRadius: radius, style: .continuous))
            case 2:
                HStack(spacing: 4) {
                    tile(attachments[0], height: 160)
                    tile(attachments[1], height: 160)
                }
                .clipShape(.rect(cornerRadius: radius, style: .continuous))
            default:
                let cols = [GridItem(.flexible(), spacing: 4), GridItem(.flexible(), spacing: 4)]
                LazyVGrid(columns: cols, spacing: 4) {
                    ForEach(attachments) { att in
                        tile(att, height: 120)
                    }
                }
                .clipShape(.rect(cornerRadius: radius, style: .continuous))
            }
        }
    }

    @ViewBuilder
    private func tile(_ attachment: ChatAttachment, height: CGFloat) -> some View {
        Color(.secondarySystemBackground)
            .frame(height: height)
            .frame(maxWidth: .infinity)
            .overlay {
                tileContent(attachment)
                    .allowsHitTesting(false)
            }
            .overlay {
                if attachment.kind == .video && playingAttachmentId != attachment.id {
                    Image(systemName: "play.fill")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 44, height: 44)
                        .background(.black.opacity(0.5), in: Circle())
                }
            }
            .contentShape(Rectangle())
            .onTapGesture {
                if attachment.kind == .video {
                    playingAttachmentId = attachment.id
                }
            }
    }

    @ViewBuilder
    private func tileContent(_ attachment: ChatAttachment) -> some View {
        if attachment.kind == .video, playingAttachmentId == attachment.id {
            VideoPlayer(player: AVPlayer(url: attachment.fileURL))
                .aspectRatio(contentMode: .fill)
        } else {
            let url = attachment.kind == .video ? attachment.thumbnailURL : attachment.fileURL
            if let url, let data = try? Data(contentsOf: url), let img = UIImage(data: data) {
                Image(uiImage: img)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else {
                Image(systemName: attachment.kind == .video ? "video" : "photo")
                    .font(.system(size: 28))
                    .foregroundStyle(.secondary)
            }
        }
    }
}
