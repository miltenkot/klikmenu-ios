import SwiftUI

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

struct CachedAsyncImage: View {
    let url: URL?
    let cacheKey: String?
    let contentMode: ContentMode

    @State private var phase: AsyncImagePhase = .empty

  init(url: URL?, cacheKey: String?, contentMode: ContentMode) {
        self.url = url
        self.cacheKey = cacheKey
        self.contentMode = contentMode
    }

    var body: some View {
        Color.clear
            .overlay {
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
            .task(id: loadIdentity) {
                await loadImage()
            }
    }

    private var loadIdentity: String {
        "\(cacheKey ?? "")|\(url?.absoluteString ?? "")"
    }

    private func loadImage() async {
        guard let url else {
            phase = .failure(URLError(.badURL))
            return
        }

        phase = .empty

        let resolvedCacheKey = cacheKey ?? url.absoluteString

        do {
            ImageURLCacheConfiguration.configureIfNeeded()
            let data = try await CachedImageLoader.shared.load(url: url, cacheKey: resolvedCacheKey)
            guard let image = platformImage(from: data) else {
                phase = .failure(ImageLoadError.invalidResponse)
                return
            }
            phase = .success(image)
        } catch {
            phase = .failure(error)
        }
    }

    private func platformImage(from data: Data) -> Image? {
        #if canImport(UIKit)
        guard let uiImage = UIImage(data: data) else { return nil }
        return Image(uiImage: uiImage)
        #elseif canImport(AppKit)
        guard let nsImage = NSImage(data: data) else { return nil }
        return Image(nsImage: nsImage)
        #else
        return nil
        #endif
    }
}
