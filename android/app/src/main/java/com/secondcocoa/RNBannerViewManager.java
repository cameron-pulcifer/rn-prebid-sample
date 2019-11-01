package com.secondcocoa;


import android.annotation.SuppressLint;
import android.graphics.Color;
import android.util.Log;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.common.MapBuilder;
import com.facebook.react.uimanager.SimpleViewManager;
import com.facebook.react.uimanager.ThemedReactContext;
import com.facebook.react.uimanager.annotations.ReactProp;
import com.facebook.react.uimanager.events.RCTEventEmitter;
import com.facebook.react.views.view.ReactViewGroup;
import com.google.android.gms.ads.AdListener;
import com.google.android.gms.ads.AdSize;
import com.google.android.gms.ads.doubleclick.AppEventListener;
import com.google.android.gms.ads.doubleclick.PublisherAdRequest;
import com.google.android.gms.ads.doubleclick.PublisherAdView;

import org.prebid.mobile.BannerAdUnit;
import org.prebid.mobile.Host;
import org.prebid.mobile.OnCompleteListener;
import org.prebid.mobile.PrebidMobile;
import org.prebid.mobile.ResultCode;
import org.prebid.mobile.addendum.AdViewUtils;
import org.prebid.mobile.addendum.PbFindSizeError;

import java.util.Map;


/**
 * View Manager for Rubicon Prebid SDK and Google Ad Manager ads
 * */
public class RNBannerViewManager extends SimpleViewManager<ReactViewGroup> implements AppEventListener {

  // private vars mapped to RN props from JS
  private String _adUnit = "";
  private String _bannerSize = "";
  // RN Android bridges
  private ThemedReactContext _reactContext;
  private RCTEventEmitter _eventEmitter;
  private ReactViewGroup _view;


  @NonNull
  @Override
  // This identifies the native component's name so JS can find it
  public String getName() {
    return "RNBannerView";
  }

  @NonNull
  @Override
  protected ReactViewGroup createViewInstance(@NonNull ThemedReactContext reactContext) {
    // Prebid setup
    PrebidMobile.setPrebidServerAccountId("1001");
    PrebidMobile.setPrebidServerHost(Host.RUBICON);
    PrebidMobile.setShareGeoLocation(true);
    PrebidMobile.setApplicationContext(reactContext);
    PrebidMobile.setStoredAuctionResponse("1001-300x250");

    // create the view instance
    this._reactContext = reactContext;
    this._eventEmitter = this._reactContext.getJSModule(RCTEventEmitter.class);
    ReactViewGroup view = new ReactViewGroup(this._reactContext);
    view.setBackgroundColor(Color.CYAN);
    _view = view;
    return view;
  }


  @ReactProp(name = "adUnit")
  public void setAdUnit(final ReactViewGroup view, String adUnit) {
    this._adUnit = adUnit;
    Log.d("CAM|adUnit", adUnit);
    loadView();
  }

  @ReactProp(name = "bannerSize")
  public void setBannerSize(final ReactViewGroup view, String bannerSize) {
    this._bannerSize = bannerSize;
    Log.d("CAM|bannerSize", bannerSize);
    loadView();
  }

  @Override
  @Nullable
  // This is how we register JS events
  // getExportedCustomBubblingEventTypeConstants vs getExportedCustomDirectEventTypeConstants
  public Map<String, Object> getExportedCustomDirectEventTypeConstants() {
    MapBuilder.Builder<String, Object> builder = MapBuilder.builder();
    // JS event names
    builder.put("onLog", MapBuilder.of("registrationName", "onLog"));
    builder.put("onDidFailToReceiveAdWithError", MapBuilder.of("registrationName", "onDidFailToReceiveAdWithError"));
    return builder.build();
  }

  /**
   * RN component implementation
   */

  private void loadView() {
    if (this._adUnit.isEmpty() || this._bannerSize.isEmpty()) {
      return;
    }

    _view.removeAllViews();

    // ad is destroyed (scrolling, etc)
    if (this._bannerSize.equals("destroy")) {
      return;
    }

    // create banner ad unit
    AdSize size = getGadAdSize(this._bannerSize);
    PublisherAdView dfpAdView = new PublisherAdView(_reactContext);
    dfpAdView.setAdUnitId("/xxxx/xxxxxxxxxxxx");
    dfpAdView.setAppEventListener(this); // not sure what this is doing from our code
    decorateAdListener(dfpAdView);
    dfpAdView.setAdSizes(size);
    _view.addView(dfpAdView);

    // Prebid code
    final PublisherAdRequest.Builder builder = new PublisherAdRequest.Builder();
    builder.addTestDevice("B3EEABB8EE11C2BE770B684D95219ECB");
    final PublisherAdRequest request = builder.build();
    BannerAdUnit bannerAdUnit = new BannerAdUnit("1001-1", size.getWidth(), size.getHeight());
    bannerAdUnit.fetchDemand(request, new OnCompleteListener() {
      @Override
      public void onComplete(ResultCode resultCode) {
        Log.d("loadAd", "\nAD finished loading... width: " + size.getWidth() + "; height: " + size.getHeight() + "\n");
        Log.d("resultCode", resultCode.toString());
        dfpAdView.loadAd(request);
      }
    });
  }

  private void decorateAdListener(PublisherAdView dfpAdView) {
    dfpAdView.setAdListener(new AdListener() {

      @Override
      public void onAdLoaded() {
        super.onAdLoaded();

        int width = dfpAdView.getAdSize().getWidthInPixels(_reactContext);
        int height = dfpAdView.getAdSize().getHeightInPixels(_reactContext);
        int left = dfpAdView.getLeft();
        int top = dfpAdView.getTop();
        dfpAdView.measure(width, height);
        dfpAdView.layout(left, top, left + width, top + height);
        dispatchJsEvent("onLog", "message", "LOADING DFP AD...");

        // return;

        AdViewUtils.findPrebidCreativeSize(dfpAdView, new AdViewUtils.PbFindSizeListener() {
          @SuppressLint("LongLogTag")
          @Override
          public void success(int width, int height) {
            dispatchJsEvent("onLog", "message", "AdViewUtils.findPrebidCreativeSize --> SUCCESS: " + width + "; " + height);
            Log.d("AdViewUtils.findPrebidCreativeSize success", "SUCCESS: " + width + "; " + height);
            dfpAdView.setAdSizes(new AdSize(width, height));

            // int left = dfpAdView.getLeft();
            // int top = dfpAdView.getTop();
            // dfpAdView.measure(width, height);
            // dfpAdView.layout(left, top, left + width, top + height);
          }

          @SuppressLint("LongLogTag")
          @Override
          public void failure(@NonNull PbFindSizeError error) {
            Log.d("AdViewUtils.findPrebidCreativeSize failure", "error: " + error);
          }
        });

      }

      @Override
      public void onAdFailedToLoad(int errorCode) {
        dispatchJsEvent("onLog", "message", "onAdFailedToLoad --> error: " + errorCode);
      }
    });
  }

  private void dispatchJsEvent(String jsEventName, String key, String value) {
    WritableMap map = Arguments.createMap();
    map.putString(key, value);
    _eventEmitter.receiveEvent(_view.getId(), jsEventName, map);
  }


    @Override
    // implements AppEventListener interface
    public void onAppEvent(String s, String s1) {

    }


    private AdSize getGadAdSize(String bannerSize) {
        switch (bannerSize) {
            case "largeBanner":
                return AdSize.LARGE_BANNER;
            case "mediumRectangle":
                return AdSize.MEDIUM_RECTANGLE;
            case "fullBanner":
                return AdSize.FULL_BANNER;
            case "leaderboard":
                return AdSize.LEADERBOARD;
            case "smartBannerPortrait":
            case "smartBanner":
            case "smartBannerLandscape":
                return AdSize.SMART_BANNER;
            default:
                return AdSize.BANNER; // case "banner"
        }
    }
}