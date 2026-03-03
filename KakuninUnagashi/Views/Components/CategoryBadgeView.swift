import SwiftUI

struct CategoryBadgeView: View {
    let category: CheckCategory

    var body: some View {
        HStack(spacing: 4) {
            Text(category.emoji)
                .font(.system(size: 14))
            Text(category.name)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(Color(hex: category.colorHex))
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color(hex: category.colorHex).opacity(0.12))
        .clipShape(Capsule())
    }
}
