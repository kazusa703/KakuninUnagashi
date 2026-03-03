import SwiftUI

// MARK: - App Color Theme

struct AppColors {
    let primaryAccent: Color
    let background: Color
    let cardBackground: Color
    let primaryText: Color
    let secondaryText: Color
    let overdueRed: Color
    let confirmedGreen: Color
    let separator: Color
}

extension AppColors {
    static let light = AppColors(
        primaryAccent: Color(hex: "#2D8CFF"),
        background: Color(hex: "#FFFFFF"),
        cardBackground: Color(hex: "#F5F5F5"),
        primaryText: Color(hex: "#1A1A1A"),
        secondaryText: Color(hex: "#8E8E93"),
        overdueRed: Color(hex: "#FF3B30"),
        confirmedGreen: Color(hex: "#34C759"),
        separator: Color(hex: "#E5E5EA")
    )

    static let dark = AppColors(
        primaryAccent: Color(hex: "#4DA3FF"),
        background: Color(hex: "#1C1C1E"),
        cardBackground: Color(hex: "#2C2C2E"),
        primaryText: Color(hex: "#F5F5F5"),
        secondaryText: Color(hex: "#8E8E93"),
        overdueRed: Color(hex: "#FF453A"),
        confirmedGreen: Color(hex: "#30D158"),
        separator: Color(hex: "#38383A")
    )
}

// MARK: - Environment Key

private struct AppColorsKey: EnvironmentKey {
    static let defaultValue = AppColors.light
}

extension EnvironmentValues {
    var appColors: AppColors {
        get { self[AppColorsKey.self] }
        set { self[AppColorsKey.self] = newValue }
    }
}

// MARK: - Color Extension

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - View Modifier for Theme

struct ThemeModifier: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme

    func body(content: Content) -> some View {
        content
            .environment(\.appColors, colorScheme == .dark ? .dark : .light)
    }
}

extension View {
    func withAppTheme() -> some View {
        modifier(ThemeModifier())
    }
}
