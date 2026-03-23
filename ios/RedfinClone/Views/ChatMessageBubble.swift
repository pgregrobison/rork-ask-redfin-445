import SwiftUI

struct ChatMessageBubble: View {
    let message: ChatMessage
    let allListings: [Listing]
    let onFeedback: (MessageFeedback) -> Void
    let onShowOnMap: ([Listing]) -> Void
    let onListingTap: (Listing) -> Void

    var body: some View {
        if message.role == .user {
            userBubble
        } else if message.role == .assistant {
            assistantBubble
        }
    }

    private var userBubble: some View {
        HStack {
            Spacer(minLength: 60)
            Text(message.content)
                .font(.body)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(Color(.systemGray6))
                .clipShape(.rect(cornerRadius: 18, style: .continuous))
        }
        .padding(.horizontal, 16)
    }

    private var assistantBubble: some View {
        VStack(alignment: .leading, spacing: 10) {
            if !message.content.isEmpty {
                Text(message.content)
                    .font(.body)
                    .textSelection(.enabled)
                    .padding(.horizontal, 16)
            }

            if let searchResults = message.searchResults, !searchResults.isEmpty {
                ChatListingCards(
                    listingIds: searchResults,
                    allListings: allListings,
                    onShowOnMap: onShowOnMap,
                    onListingTap: onListingTap
                )
            }

            if let tourRequest = message.tourRequest {
                TourSchedulerWidget(tourRequest: tourRequest)
            }

            if let mortgageRequest = message.mortgageRequest {
                MortgagePrequalWidget(mortgageRequest: mortgageRequest)
            }

            if message.isTourRoute {
                TourRouteMapWidget()
            }

            if message.role == .assistant && !message.content.isEmpty && !message.isStreaming {
                feedbackButtons
            }
        }
    }

    private var feedbackButtons: some View {
        HStack(spacing: 8) {
            Button { onFeedback(.thumbsUp) } label: {
                Image(systemName: message.feedback == .thumbsUp ? "hand.thumbsup.fill" : "hand.thumbsup")
                    .font(.system(size: Theme.IconSize.small, weight: .semibold))
                    .contentTransition(.symbolEffect(.replace))
                    .foregroundStyle(message.feedback == .thumbsUp ? .primary : Color.secondary.opacity(0.5))
                    .frame(width: Theme.IconSize.smallTap, height: Theme.IconSize.smallTap)
                    .contentShape(Rectangle())
            }

            Button { onFeedback(.thumbsDown) } label: {
                Image(systemName: message.feedback == .thumbsDown ? "hand.thumbsdown.fill" : "hand.thumbsdown")
                    .font(.system(size: Theme.IconSize.small, weight: .semibold))
                    .contentTransition(.symbolEffect(.replace))
                    .foregroundStyle(message.feedback == .thumbsDown ? .primary : Color.secondary.opacity(0.5))
                    .frame(width: Theme.IconSize.smallTap, height: Theme.IconSize.smallTap)
                    .contentShape(Rectangle())
            }
        }
        .padding(.horizontal, 16)
    }
}
