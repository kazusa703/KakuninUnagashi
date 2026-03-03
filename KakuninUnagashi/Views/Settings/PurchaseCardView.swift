import StoreKit
import SwiftUI

struct PurchaseCardView: View {
    @Environment(\.appColors) private var colors
    let storeKitManager: StoreKitManager

    var body: some View {
        CustomCardView {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "sparkles")
                        .font(.system(size: 20))
                        .foregroundStyle(colors.primaryAccent)
                    Text(String(localized: "広告を非表示にする", comment: "Remove ads"))
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(colors.primaryText)
                }

                if storeKitManager.isAdRemoved {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(colors.confirmedGreen)
                        Text(String(localized: "広告非表示: 有効", comment: "Ads removed"))
                            .font(.system(size: 15))
                            .foregroundStyle(colors.confirmedGreen)
                    }
                } else {
                    Text(String(localized: "一度の購入で広告を永久に非表示にできます", comment: "Purchase description"))
                        .font(DesignTokens.captionFont)
                        .foregroundStyle(colors.secondaryText)

                    Button {
                        Task { await storeKitManager.purchase() }
                    } label: {
                        HStack {
                            Text(String(localized: "購入する", comment: "Purchase button"))
                                .font(.system(size: 16, weight: .semibold))
                            Spacer()
                            if let product = storeKitManager.product {
                                Text(product.displayPrice)
                                    .font(.system(size: 16, weight: .bold))
                            }
                        }
                        .foregroundStyle(.white)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 16)
                        .background(colors.primaryAccent)
                        .clipShape(RoundedRectangle(cornerRadius: DesignTokens.buttonCornerRadius))
                    }

                    if let error = storeKitManager.purchaseError {
                        Text(error)
                            .font(DesignTokens.captionFont)
                            .foregroundStyle(colors.overdueRed)
                    }
                }
            }
            .padding(DesignTokens.horizontalPadding)
        }
    }
}
