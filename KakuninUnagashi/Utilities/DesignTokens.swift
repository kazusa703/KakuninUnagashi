import SwiftUI

enum DesignTokens {
    // MARK: - Corner Radius

    static let cardCornerRadius: CGFloat = 14
    static let buttonCornerRadius: CGFloat = 10

    // MARK: - Padding

    static let rowVerticalPadding: CGFloat = 14
    static let horizontalPadding: CGFloat = 16

    // MARK: - Separator

    static let separatorHeight: CGFloat = 0.5

    // MARK: - Grid

    static let gridUnit: CGFloat = 8

    // MARK: - Typography

    static let dateHeaderFont: Font = .system(size: 28, weight: .bold)
    static let categoryHeaderFont: Font = .system(size: 16, weight: .semibold)
    static let itemNameFont: Font = .system(size: 17, weight: .medium)
    static let daysRemainingFont: Font = .system(size: 22, weight: .bold)
    static let captionFont: Font = .system(size: 13, weight: .regular)
    static let tabLabelFont: Font = .system(size: 10, weight: .regular)
    static let navTitleFont: Font = .system(size: 20, weight: .bold)
    static let detailTitleFont: Font = .system(size: 24, weight: .bold)

    // MARK: - Filter Bar

    static let filterUnderlineHeight: CGFloat = 3

    // MARK: - FAB

    static let fabSize: CGFloat = 56
    static let fabIconSize: CGFloat = 24

    // MARK: - Animation

    static let confirmAnimationDuration: Double = 0.3
    static let springAnimation: Animation = .spring(response: 0.35, dampingFraction: 0.7)
}
