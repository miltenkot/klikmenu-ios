import SwiftUI

public struct RemoteImageView: View {
    public let url: URL?
    public var cacheKey: String?
    public var contentMode: ContentMode = .fill

    public init(url: URL?, cacheKey: String? = nil, contentMode: ContentMode = .fill) {
        self.url = url
        self.cacheKey = cacheKey
        self.contentMode = contentMode
    }

    public var body: some View {
        Color.clear
            .overlay {
                if let url {
                    #if os(iOS)
                    if #available(iOS 27.0, *) {
                        AsyncImage(url: url) { phase in
                            imagePhaseContent(phase)
                        }
                    } else {
                        CachedAsyncImage(url: url, cacheKey: cacheKey, contentMode: contentMode)
                    }
                    #else
                    CachedAsyncImage(url: url, cacheKey: cacheKey, contentMode: contentMode)
                    #endif
                }
            }
            .clipped()
            .allowsHitTesting(false)
            .accessibilityHidden(true)
    }

    @ViewBuilder
    private func imagePhaseContent(_ phase: AsyncImagePhase) -> some View {
        switch phase {
        case .empty:
            Color.clear
        case .success(let image):
            image
                .resizable()
                .aspectRatio(contentMode: contentMode)
        case .failure:
            Color.clear
        @unknown default:
            Color.clear
        }
    }
}
