import SwiftUI

struct TagView: View {
    let text: String

    var body: some View {
        Text(text)
            .font(Theme.Tag.font)
            .lineLimit(1)
            .padding(.horizontal, Theme.Tag.horizontalPadding)
            .padding(.vertical, Theme.Tag.verticalPadding)
            .background(Theme.Tag.background)
            .clipShape(.rect(cornerRadius: Theme.Tag.cornerRadius))
    }
}

struct TagRow: View {
    let tags: [String]
    var maxCount: Int = Theme.Tag.rowMaxCount

    var body: some View {
        HStack(spacing: Theme.Tag.rowSpacing) {
            ForEach(tags.prefix(maxCount), id: \.self) { tag in
                TagView(text: tag)
            }
        }
    }
}

struct TagGrid: View {
    let tags: [String]

    var body: some View {
        LazyVGrid(
            columns: [GridItem(.adaptive(minimum: Theme.Tag.gridMinimum), spacing: Theme.Tag.gridSpacing)],
            alignment: .leading,
            spacing: Theme.Tag.gridSpacing
        ) {
            ForEach(tags, id: \.self) { tag in
                TagView(text: tag)
            }
        }
    }
}
