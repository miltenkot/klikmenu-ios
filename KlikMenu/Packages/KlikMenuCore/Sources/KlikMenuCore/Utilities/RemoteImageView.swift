import SwiftUI

public struct RemoteImageView: View {
    public let url: URL?
    public var contentMode: ContentMode = .fill

    public init(url: URL?, contentMode: ContentMode = .fill) {
        self.url = url
        self.contentMode = contentMode
    }

    public var body: some View {
        Color.clear
            .overlay {
                if let url {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            placeholder
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: contentMode)
                        case .failure:
                            placeholder
                        @unknown default:
                            placeholder
                        }
                    }
                } else {
                    placeholder
                }
            }
            .clipped()
            .accessibilityHidden(true)
    }

    private var placeholder: some View {
        Rectangle()
            .fill(Color.klikBrand.opacity(0.18))
            .overlay {
                Image(systemName: "photo")
                    .font(.title2)
                    .foregroundStyle(Color.klikBrand.opacity(0.55))
            }
    }
}
