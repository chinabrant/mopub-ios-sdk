//
//  ContainerViewController.swift
//
//  Copyright 2018-2021 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

import AppTrackingTransparency
import MoPubSDK
import UIKit

class ContainerViewController: UIViewController {
    // Constants
    struct Constants {
        static let menuAnimationDuration: TimeInterval = 0.25 //seconds
    }
    
    // MARK: - IBOutlets
    @IBOutlet weak var menuContainerLeadingEdgeConstraint: NSLayoutConstraint!
    @IBOutlet weak var menuContainerWidthConstraint: NSLayoutConstraint!
    
    // MARK: - Menu Gesture Recognizers
    
    private var menuCloseGestureRecognizer: UISwipeGestureRecognizer!
    private var menuCloseTapGestureRecognizer: UITapGestureRecognizer!
    private var menuOpenGestureRecognizer: UISwipeGestureRecognizer!
    
    // MARK: - Properties
    
    /**
     Current collection of override traits for mainTabBarController.
     */
    var forcedTraitCollection: UITraitCollection?  = nil {
        didSet {
            updateForcedTraitCollection()
        }
    }
    
    /**
     Main TabBar Controller of the app.
     */
    private(set) var mainTabBarController: MainTabBarController? = nil
    
    /**
     Menu TableView Controller of the app.
     */
    private(set) var menuViewController: MenuViewController? = nil
    
    var savedAdsNavigationController: UINavigationController {
        guard let mainTabBarController = mainTabBarController else {
            fatalError()
        }
        return mainTabBarController.savedAdsNavigationController
    }
    
    // MARK: - Forced Traits
    
    func setForcedTraits(for size: CGSize) {
        let device = traitCollection.userInterfaceIdiom
        let isPortrait: Bool = view.bounds.size.width < view.bounds.size.height
        
        switch (device, isPortrait) {
        case (.pad, true): forcedTraitCollection = UITraitCollection(horizontalSizeClass: .compact)
        default: forcedTraitCollection = nil
        }
    }
    
    /**
     Updates the Main Tab Bar controller with the new trait overrides.
     */
    func updateForcedTraitCollection() {
        if let vc = mainTabBarController {
            setOverrideTraitCollection(forcedTraitCollection, forChild: vc)
        }
    }
    
    // MARK: - Segues
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // When the children view controllers are loaded, each will perform
        // a segue which we must capture to initialize the view controller
        // properties.
        switch segue.identifier {
        case "onEmbedTabBarController":
            mainTabBarController = segue.destination as? MainTabBarController
            break
        case "onEmbedMenuController":
            menuViewController = segue.destination as? MenuViewController
            break
        default:
            break
        }
    }
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Register for `didBecomeActiveNotification` notification to initialize the
        // MoPub SDK due to iOS 15 changes where the ATT ptompt is no longer able to
        // be called as part of the normal initialization flow.
        NotificationCenter.default.addObserver(self, selector: #selector(checkAndInitializeSdk(_:)), name: UIApplication.didBecomeActiveNotification, object: nil)
        
        // Setup trait overrides
        setForcedTraits(for: view.bounds.size)
        
        // Initialize the gesture recognizers and attach them to the view.
        menuCloseGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(swipeMenuClose(_:)))
        menuCloseGestureRecognizer.direction = .left
        view.addGestureRecognizer(menuCloseGestureRecognizer)
        
        menuCloseTapGestureRecognizer = UITapGestureRecognizer (target: self, action: #selector(tapMenuClose(_:)))
        menuCloseTapGestureRecognizer.isEnabled = false
        menuCloseTapGestureRecognizer.delegate = self
        view.addGestureRecognizer(menuCloseTapGestureRecognizer)
        
        menuOpenGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(swipeMenuOpen(_:)))
        menuOpenGestureRecognizer.direction = .right
        view.addGestureRecognizer(menuOpenGestureRecognizer)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: { _ in
            self.setForcedTraits(for: size)
        }, completion: nil)
    }

    // MARK: - Menu
    
    /**
     Closes the menu if it open.
     */
    func closeMenu() {
        swipeMenuClose(menuCloseGestureRecognizer)
    }
    
    @objc func swipeMenuClose(_ sender: UISwipeGestureRecognizer) {
        // Do nothing if the menu is not fully open since it may either
        // be closed, or in the process of being closed.
        guard menuContainerLeadingEdgeConstraint.constant == 0 else {
            return
        }
        
        // Disable the tap outside of menu to close gesture recognizer.
        menuCloseTapGestureRecognizer.isEnabled = false
        
        // Close the menu by setting the leading edge constraint to the negative width,
        // which will put it offscreen.
        UIView.animate(withDuration: Constants.menuAnimationDuration, animations: {
            self.menuContainerLeadingEdgeConstraint.constant = -self.menuContainerWidthConstraint.constant
            self.view.layoutIfNeeded()
        }) { _ in
            // Re-enable user interaction for the main content container.
            self.mainTabBarController?.view.isUserInteractionEnabled = true
        }
    }
    
    @objc func swipeMenuOpen(_ sender: Any) {
        // Do nothing if the menu is already open or in the process of opening.
        guard (menuContainerWidthConstraint.constant + menuContainerLeadingEdgeConstraint.constant) == 0 else {
            return
        }
        
        // Disable user interaction for the main content container.
        self.mainTabBarController?.view.isUserInteractionEnabled = false
        
        // Open the menu by setting the leading edge constraint back to zero.
        UIView.animate(withDuration: Constants.menuAnimationDuration, animations: {
            self.menuContainerLeadingEdgeConstraint.constant = 0
            self.view.layoutIfNeeded()
        }) { _ in
            // Enable the tap outside of menu to close gesture recognizer.
            self.menuCloseTapGestureRecognizer.isEnabled = true
        }
    }
    
    @objc func tapMenuClose(_ sender: UITapGestureRecognizer) {
        // Allow any previously queued animations to finish before attempting to close the menu
        view.layoutIfNeeded()
        
        // Close the menu
        closeMenu()
    }
}

extension ContainerViewController: UIGestureRecognizerDelegate {
    // MARK: - UIGestureRecognizerDelegate
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        // Only handle the menu tap to close gesture
        guard gestureRecognizer == menuCloseTapGestureRecognizer else {
            return true
        }
        
        // If the menu is not fully open, disregard the tap.
        guard menuContainerLeadingEdgeConstraint.constant == 0 else {
            return false
        }
        
        // If the tap intersects the open menu, disregard the tap.
        guard gestureRecognizer.location(in: view).x > menuContainerWidthConstraint.constant else {
            return false
        }
        
        return true
    }
}

// MARK: - Private App Init

fileprivate extension ContainerViewController {
    static var hasInitialized: Bool = false
    
    @objc func checkAndInitializeSdk(_  notification: Notification) {
        // Only attempt initialization once.
        guard ContainerViewController.hasInitialized == false else {
            return
        }
        
        ContainerViewController.hasInitialized = true
        checkAndInitializeSdk(userDefaults: .standard)
    }
    
    /**
     Attempts to display the tracking authorization prompt. At completion, will check if the Canary app has a cached ad unit ID for consent. If not, the app will present an alert dialog allowing custom ad unit ID entry.
     - Parameter containerViewController: the main container view controller
     - Parameter userDefaults: the target `UserDefaults` instance
     */
    func checkAndInitializeSdk(userDefaults: UserDefaults = .standard) {
        // Prompt for authorization status, then run the `initializeMoPubSDK` method (which
        // also shows the GDPR prompt, if available) at completion so Canary isn't trying to present two
        // view controllers simultaneously
        promptForTrackingAuthorizationStatus(fromViewController: self) { [weak self] in
            // Obtain strong reference to self, otherwise don't bother.
            guard let self = self else { return }
            
            // Retrieve the ad unit used to initialize the SDK.
            let adUnitIdForConsent: String = userDefaults.cachedAdUnitId ?? "0ac59b0996d947309c33f59d6676399f"
            
            // Next, initialize the SDK
            self.initializeMoPubSdk(adUnitIdForConsent: adUnitIdForConsent, containerViewController: self, mopub: MoPub.sharedInstance())
        }
    }

    private func promptForTrackingAuthorizationStatus(fromViewController viewController: UIViewController, completion: (() -> Void)? = nil) {
        // If tracking authorization status is equal to `.notDetermined`, prompt
        // to see if Canary should ask for authorization permission.
        // Doing this check before actually requesting permission allows Canary
        // to black-box test `.notDetermined` status, as well as `.authorized`
        // and `.denied`. Not showing the prompt makes it so `.notDetermined`
        // cannot be properly tested as the call to `requestTrackingAuthorization`
        // forces a state-change to strictly `.denied` or `.authorized`.
        
        guard #available(iOS 14.0, *) else {
            // Not running iOS 14
            completion?()
            return
        }
        
        guard ATTrackingManager.trackingAuthorizationStatus == .notDetermined else {
            // Already have an authorization status; don't need to reprompt
            completion?()
            return
        }
        
        ATTrackingManager.requestTrackingAuthorization { _ in
            // Request completed; call completion
            completion?()
        }
    }

    /**
     Initializes the MoPub SDK with the given ad unit ID used for consent management.
     - Parameter adUnitIdForConsent: This value must be a valid ad unit ID associated with your app.
     - Parameter containerViewController: the main container view controller
     - Parameter mopub: the target `MoPub` instance
     */
    func initializeMoPubSdk(adUnitIdForConsent: String,
                            containerViewController: ContainerViewController,
                            mopub: MoPub = .sharedInstance(),
                            completion: (() -> Void)? = nil) {
        // MoPub SDK initialization
        let sdkConfig = MPMoPubConfiguration(adUnitIdForAppInitialization: adUnitIdForConsent)
        sdkConfig.globalMediationSettings = []
        sdkConfig.loggingLevel = .info
        
        mopub.initializeSdk(with: sdkConfig) {
            // Update the state of the menu now that the SDK has completed initialization.
            if let menuController = containerViewController.menuViewController {
                menuController.updateIfNeeded()
            }
            
            // Request user consent to collect personally identifiable information
            // used for targeted ads
            if let tabBarController = containerViewController.mainTabBarController {
                ContainerViewController.displayConsentDialog(from: tabBarController, mopub: mopub) {
                    completion?()
                }
            }
        }
    }
}

// MARK: - Private Helpers

fileprivate extension ContainerViewController {
    /**
     Loads the consent request dialog (if not already loaded), and presents the dialog
     from the specified view controller. If user consent is not needed, nothing is done.
     - Parameter presentingViewController: `UIViewController` used for presenting the dialog
     - Parameter mopub: the target `MoPub` instance
     */
    static func displayConsentDialog(from presentingViewController: UIViewController,
                                     mopub: MoPub = .sharedInstance(),
                                     completion: (() -> Void)? = nil) {
        // Verify that we need to acquire consent.
        guard mopub.shouldShowConsentDialog else {
            completion?()
            return
        }
        
        // Load the consent dialog if it's not available. If it is already available,
        // the completion block will immediately fire.
        mopub.loadConsentDialog { (error: Error?) in
            guard error == nil else {
                print("Consent dialog failed to load: \(String(describing: error?.localizedDescription))")
                completion?()
                return
            }
            
            mopub.showConsentDialog(from: presentingViewController, didShow: nil) {
                completion?()
            }
        }
    }
}
