import SwiftUI

struct FeedbackWaiterAvatarView: View {
    let waiter: PublicWaiter

    var body: some View {
        if waiter.photoURL != nil {
            RemoteImageView(url: waiter.photoURL, cacheKey: waiter.id)
                .frame(width: 40, height: 40)
                .clipShape(Circle())
        } else {
            Circle()
                .fill(Color.klikBrand.opacity(0.15))
                .frame(width: 40, height: 40)
                .overlay {
                    Text(waiter.initial)
                        .font(.headline)
                        .foregroundStyle(Color.klikBrand)
                }
                .accessibilityHidden(true)
        }
    }
}
