import SwiftUI

struct MenuLoadingSkeletonCard: View {
    let isPulsing: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            MenuLoadingSkeletonBar(width: 132, height: 16)

            ForEach(0..<3, id: \.self) { index in
                HStack(alignment: .center, spacing: 12) {
                    VStack(alignment: .leading, spacing: 8) {
                        MenuLoadingSkeletonBar(height: 14)
                        MenuLoadingSkeletonBar(width: index == 1 ? 168 : 210, height: 10)
                    }
                    Spacer(minLength: 12)
                    MenuLoadingSkeletonBar(width: 52, height: 14)
                }
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background { Color.klikSurface }
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .opacity(isPulsing ? 1 : 0.55)
    }
}

struct MenuLoadingSkeletonBar: View {
    var width: CGFloat?
    var height: CGFloat

    var body: some View {
        RoundedRectangle(cornerRadius: 6, style: .continuous)
            .fill(Color.klikBorder.opacity(0.65))
            .frame(width: width, height: height)
            .frame(maxWidth: width == nil ? .infinity : nil, alignment: .leading)
    }
}
