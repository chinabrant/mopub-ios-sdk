//
//  SceneDelegate.swift
//
//  Copyright 2018-2021 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

import MoPubSDK
import UIKit
import AppTrackingTransparency

private let kAppId = "112358"

class SceneDelegate: UIResponder {
    /**
     Possible modes of this scene delegate.
     */
    enum Mode {
        /**
         This `SceneDelegate` is instantiated but not yet assgined to a particular scene.
         */
        case unknown
        
        /**
         This represents the one & only main scene of this app.
         */
        case mainScene(mainSceneState: MainSceneState)
        
        /**
         This represents a dedicated scene for showing a ad.
         */
        case adViewScene
    }
    
    /**
     This is the data container for `Mode.mainScene`.
    */
    struct MainSceneState {
        /**
         Scene container controller. Assignment deferred to `handleMainSceneStart`.
         */
        let containerViewController: ContainerViewController
        
        
        
        init(containerViewController: ContainerViewController) {
            self.containerViewController = containerViewController
            
        }
    }
    
    /**
     Use this to handle the one-off app init events.
     */
    static var didHandleAppInit = false
    
    /**
     Scene window.
     */
    var window: UIWindow?
    
    /**
     Current mode of the scene delegates. Should be assigned in `scene(_:willConnectTo:options:)`.
    */
    private(set) var mode: Mode = .unknown
    
    /**
     Handle the start event of the main scene.
     
     Call this to when:
        * Pre iOS 13: application did finish launching (as single scene)
        * iOS 13+: scene will connect to session
     
     - Parameter mopub: the target `MoPub` instance
     - Parameter adConversionTracker: the target `MPAdConversionTracker` instance
     - Parameter userDefaults: the target `UserDefaults` instance
    */
    func handleMainSceneStart(mopub: MoPub = .sharedInstance(),
                              adConversionTracker: MPAdConversionTracker = .shared(),
                              userDefaults: UserDefaults = .standard) {
        // Extract the UI elements for easier manipulation later. Calls to `loadViewIfNeeded()` are
        // needed to load any children view controllers before `viewDidLoad()` occurs.
        guard let containerViewController = window?.rootViewController as? ContainerViewController else {
            fatalError()
        }
        containerViewController.loadViewIfNeeded()
        
        mode = .mainScene(mainSceneState: MainSceneState(containerViewController: containerViewController))
        
        if userDefaults.shouldClearCachedNetworks {
            mopub.clearCachedNetworks() // do this before initializing the MoPub SDK
            print("\(#function) cached networks are cleared")
        }

        // Make one-off calls here
        if (SceneDelegate.didHandleAppInit == false) {
            SceneDelegate.didHandleAppInit = true
            
            // Register app conversion.
            // This is for SKAdNetwork advertising campaigns that use this app
            // as the target installed app.
            if #available(iOS 11.3, *) {
                SKAdNetwork.registerAppForAdNetworkAttribution()
            }

            // Conversion tracking
            adConversionTracker.reportApplicationOpen(forApplicationID: kAppId)
        }
    }
    
    /**
     Attempts to open a URL.
     - Parameter url: the URL to open
     - Returns: `true` if successfully open, `false` if not
    */
    @discardableResult
    func openURL(_ url: URL) -> Bool {
        switch mode {
        case .mainScene(let mainSceneState):
            guard
                url.scheme == "mopub",
                url.host == "load",
                let adUnit = AdUnit(url: url) else {
                    return false
            }
            return SceneDelegate.openMoPubAdUnit(adUnit: adUnit,
                                                 onto: mainSceneState.containerViewController,
                                                 shouldSave: true)
        case .adViewScene, .unknown:
            return false
        }
    }
    
    /**
     Attempts to open a valid `AdUnit` object instance
     - Parameter adUnit: MoPub `AdUnit` object instance
     - Parameter containerViewController: Container view controller that will present the opened deep link
     - Parameter shouldSave: Flag indicating that the ad unit that was opened should be saved
     - Parameter savedAdsManager: The manager for saving the ad unit
     - Returns: `true` if successfully shown, `false` if not
     */
    @discardableResult
    static func openMoPubAdUnit(adUnit: AdUnit,
                                onto containerViewController: ContainerViewController,
                                shouldSave: Bool,
                                savedAdsManager: SavedAdsManager = .sharedInstance) -> Bool {
        // Generate the destinate view controller and attempt to push the destination to the
        // Saved Ads navigation controller.
        guard
            let vcClass = NSClassFromString(adUnit.viewControllerClassName) as? AdViewController.Type,
            let destination: UIViewController = vcClass.instantiateFromNib(adUnit: adUnit) as? UIViewController else {
                return false
        }
        
        DispatchQueue.main.async {
            // If the ad unit should be saved, we will switch the tab to the saved ads
            // tab and then push the view controller on that navigation stack.
            containerViewController.mainTabBarController?.selectedIndex = 1
            if shouldSave {
                savedAdsManager.addSavedAd(adUnit: adUnit)
            }
            containerViewController.savedAdsNavigationController.pushViewController(destination, animated: true)
        }
        return true
    }
}

// MARK: - UIWindowSceneDelegate

/*
 For future `UIWindowSceneDelegate` implementation, if there is a `UIApplicationDelegate` counterpart,
 we should share the implementation in `SceneDelegate` for both `UIWindowSceneDelegate` and
 `UIApplicationDelegate`.
 */
@available(iOS 13, *)
extension SceneDelegate: UIWindowSceneDelegate {
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let windowScene = scene as? UIWindowScene else {
            return
        }
        
        if let rootViewController = AdUnit.adViewControllerForSceneConnectionOptions(connectionOptions) {
            // load the view programmatically
            let window = UIWindow(windowScene: windowScene)
            window.rootViewController = rootViewController
            window.makeKeyAndVisible()
            self.window = window
            self.mode = .adViewScene
        } else {
            handleMainSceneStart()
        }
    }
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        // Options are specified in the UIApplication.h section for openURL options.
        // An empty options dictionary will result in the same behavior as the older openURL call,
        // aside from the fact that this is asynchronous and calls the completion handler rather
        // than returning a result. The completion handler is called on the main queue.
        for urlContext in URLContexts {
            openURL(urlContext.url)
        }
    }
}
