// core packages
import CoreLocation
import UIKit
// 3rd party packages
import GoogleMobileAds
import PrebidMobile

class PrebidBanner: UIView, GADBannerViewDelegate {
  
  // global vars
  var coreLocation: CLLocationManager?
  var dfpBannerView: DFPBannerView!

  
  // init
  override init(frame: CGRect) {
    super.init(frame: frame)
    // will be late, but do it here to see if it will work
    Prebid.shared.prebidServerHost = PrebidHost.Rubicon;
    Prebid.shared.prebidServerAccountId = "1001"
    Prebid.shared.shareGeoLocation = true
    Prebid.shared.storedAuctionResponse = "1001-300x250" // "1001-rubicon-300x250"
//    coreLocation = CLLocationManager()
//    coreLocation?.requestWhenInUseAuthorization()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // RN props
  @objc var bannerSize: NSString = "" {
    didSet {
      print("\nreached bannerSize didSet: \(bannerSize)\n")
      loadView()
    }
  }
  
  // RN props
  @objc var adUnit: NSString = "" {
    didSet {
      print("\nreached adUnit didSet: \(adUnit)\n")
      loadView()
    }
  }
  
  // exposed to RN as function
  @objc var onClick: RCTDirectEventBlock?
  @objc var onDidFailToReceiveAdWithError: RCTDirectEventBlock?
  @objc var onLog: RCTDirectEventBlock?
  
  func loadView() {
    
    if self.adUnit == "" || self.bannerSize == "" {
      print("\nProps not ready. Banner: \(self.bannerSize) | Ad Unit: \(self.adUnit)\n")
      return
    }
    
    if let viewWithTag = self.viewWithTag(100) {
      viewWithTag.removeFromSuperview()
    }
    
    if self.bannerSize == "destroy" {
      print("\n\nDestroyed \(self.subviews.count)\n\n")
      return
    }
    
    let adSize = self.getGadAdSize(self.bannerSize)
    
    // Create the ad unit(s) - this is an example for a Banner ad unit
    let bannerUnit = BannerAdUnit(
      configId: "1001-1",
      // configId: String(self.adUnit),
      size: adSize.size
    )
    
    print("Google Mobile Ads SDK version: \(DFPRequest.sdkVersion())")
    
    let request = DFPRequest()
    request.testDevices = [ kGADSimulatorID ];
    
    dfpBannerView = DFPBannerView(adSize: adSize)
    dfpBannerView.tag = 100
    dfpBannerView.delegate = self
    dfpBannerView.adUnitID = "/xxx/xxxxxxxx"
    // dfpBannerView.adUnitID = String(self.adUnit)
    dfpBannerView.rootViewController = UIApplication.shared.keyWindow!.rootViewController
    
    dfpBannerView.backgroundColor = .orange
    addSubview(self.dfpBannerView)

    bannerUnit.fetchDemand(adObject: request) { [weak self] (resultCode: ResultCode) in
      print("\nPrebid demand fetch for DFP \(resultCode.name())\n\n")
      self?.onLog!(["message": resultCode.name()])
      // Load the dfp request
      self?.dfpBannerView!.load(request)
    }
    
  }
  
  func getGadAdSize(_ bannerSize:NSString) -> GADAdSize {
    if bannerSize == "banner" {
      return kGADAdSizeBanner
    } else if bannerSize == "largeBanner" {
      return kGADAdSizeLargeBanner
    } else if bannerSize == "mediumRectangle" {
      return kGADAdSizeMediumRectangle
    } else if bannerSize == "fullBanner" {
      return kGADAdSizeFullBanner
    } else if bannerSize == "leaderboard" {
      return kGADAdSizeLeaderboard
    } else if bannerSize == "smartBannerPortrait" {
      return kGADAdSizeSmartBannerPortrait
    } else if bannerSize == "smartBannerLandscape" {
      return kGADAdSizeSmartBannerLandscape
    } else {
      return kGADAdSizeBanner
    }
  }
  
  // GADBannerViewDelegate implementation
  func adViewDidReceiveAd(_ bannerView: GADBannerView) {
      print("GADBannerView - adViewDidReceiveAd")
      print("\nType: \(type(of: bannerView))\n")
      
      AdViewUtils.findPrebidCreativeSize(bannerView,
        success: { (size) in
          guard let bannerView = bannerView as? DFPBannerView else {
            return
          }
          print("DUDE!!!!!")
          bannerView.resize(GADAdSizeFromCGSize(size))
      },
      failure: { (error) in
        print("FAILRE!!!!!")
        print("error: \(error)");
      })
  }
  
  func adView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: GADRequestError) {
    print("GADBannerView - adView:didFailToReceiveAdWithError: \(error.localizedDescription)")
    self.onDidFailToReceiveAdWithError!(["error": error.localizedDescription])
  }

  func adViewDidReceiveAd(_ bannerView: DFPBannerView) {
    print("DFPBannerView - adViewDidReceiveAd")
    self.dfpBannerView.resize(bannerView.adSize)
  }
  
  /// Tells the delegate an ad request failed.
  func adView(_ bannerView: DFPBannerView, didFailToReceiveAdWithError error: GADRequestError) {
      print("DFPBannerView - adView:didFailToReceiveAdWithError: \(error.localizedDescription)")
  }

  
}
