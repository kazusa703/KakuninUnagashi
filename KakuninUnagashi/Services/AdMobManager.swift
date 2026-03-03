import GoogleMobileAds
import SwiftUI

// MARK: - Banner Ad View (UIViewRepresentable)

struct BannerAdView: UIViewRepresentable {
    let adUnitID: String

    func makeUIView(context _: Context) -> BannerView {
        let bannerView = BannerView(adSize: AdSizeBanner)
        bannerView.adUnitID = adUnitID
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first?.rootViewController
        {
            bannerView.rootViewController = rootVC
        }
        bannerView.load(Request())
        return bannerView
    }

    func updateUIView(_: BannerView, context _: Context) {}
}

// MARK: - Ad Container View

struct AdBannerContainer: View {
    let storeKitManager: StoreKitManager

    /// Test ad unit ID for development
    private let adUnitID = "ca-app-pub-3940256099942544/2934735716"

    var body: some View {
        if !storeKitManager.isAdRemoved {
            BannerAdView(adUnitID: adUnitID)
                .frame(height: 50)
        }
    }
}

// MARK: - ATT Request

import AppTrackingTransparency

enum ATTManager {
    static func requestTrackingPermission() {
        guard ATTrackingManager.trackingAuthorizationStatus == .notDetermined else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            ATTrackingManager.requestTrackingAuthorization { _ in }
        }
    }
}
