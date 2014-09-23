//
//  ViewController.swift
//  GrandEntrance
//
//  Created by Alexander Simson on 2014-08-14.
//  Copyright (c) 2014 Simson Creative Solutions. All rights reserved.
//

import UIKit
import QuartzCore
import AudioToolbox

class ViewController: UIViewController, SearchViewControllerDelegate, ESTBeaconManagerDelegate, UIViewControllerTransitioningDelegate {
    
    @IBOutlet weak var trackLabel: UILabel!
    @IBOutlet weak var loadingLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var successView: UIView!
    @IBOutlet weak var successImageView: UIImageView!
    @IBOutlet weak var successLabel: UILabel!
    @IBOutlet weak var resetView: UIView!
    
    var baseURLString = "http://10.0.1.3:3000"
    let locationManager: CLLocationManager = CLLocationManager()
    let beaconManager: ESTBeaconManager = ESTBeaconManager()
    var numberOfDiscoveries = 0
    let soundEffect: SystemSoundID = createSoundEffect()
    var region : ESTBeaconRegion?
    var track: SearchItem? {
        didSet {
            if let title = track?.title {
                let attributes = [ NSFontAttributeName: UIFont.systemFontOfSize(24.0) ]
                let text = NSString(format: "Selected track:\n %@", title)
                let attributedString = NSMutableAttributedString(string: text)
                attributedString.setAttributes(attributes, range: text.rangeOfString(title))
                self.trackLabel.attributedText = attributedString
                self.trackLabel.hidden = false;
            } else {
                self.trackLabel.hidden = true;
            }
        }
    }
    
    override func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    override func motionEnded(motion: UIEventSubtype, withEvent event: UIEvent) {
        if motion == UIEventSubtype.MotionShake && !self.resetView.hidden {
            self.restoreView()
        }
    }
    
    func showSuccess() {
        self.successView.layer.opacity = 0.0
        self.successImageView.image = UIImage(named: "radar.png")
        self.successLabel.text = "Found Beacon"
        
        AudioServicesPlaySystemSound(soundEffect)
        
        let opacityAnimation = POPBasicAnimation()
        opacityAnimation.property = POPAnimatableProperty(name: kPOPLayerOpacity)
        opacityAnimation.toValue = 0.9;
        opacityAnimation.fromValue = 0.0
        
        let scaleAnimation = POPSpringAnimation(tension: 100, friction: 10, mass: 1)
        scaleAnimation.property = POPAnimatableProperty(name: kPOPLayerScaleXY)
        scaleAnimation.springBounciness = 15.0
        scaleAnimation.fromValue = NSValue(CGPoint: CGPointMake(0.5, 0.5))
        scaleAnimation.toValue = NSValue(CGPoint: CGPointMake(1.0, 1.0))
        
        addAnimation(opacityAnimation, opacityAnimation.property.name, self.successView.layer)
        addAnimation(scaleAnimation, scaleAnimation.property.name, self.successView.layer)
        self.successView.hidden = false
        
        var delay = 1.0 * Double(NSEC_PER_SEC)
        var time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
        dispatch_after(time, dispatch_get_main_queue(), {
            self.successImageView.image = UIImage(named: "note.png")
            self.successLabel.text = "Playing Entrace Song"
            let transition = CATransition()
            transition.duration = 0.35;
            transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
            transition.type = kCATransitionFade;
            self.successImageView.layer.addAnimation(transition, forKey: "transition")
            self.successLabel.layer.addAnimation(transition, forKey: "transition")
        })
        
        delay = 3.0 * Double(NSEC_PER_SEC)
        time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
        dispatch_after(time, dispatch_get_main_queue(), {
            let opacityAnimation = POPBasicAnimation()
            opacityAnimation.property = POPAnimatableProperty(name: kPOPLayerOpacity)
            opacityAnimation.toValue = 0.0;
            opacityAnimation.fromValue = 1.0
            
            let scaleAnimation = POPSpringAnimation(tension: 100, friction: 10, mass: 1)
            scaleAnimation.property = POPAnimatableProperty(name: kPOPLayerScaleXY)
            scaleAnimation.springBounciness = 15.0
            scaleAnimation.fromValue = NSValue(CGPoint: CGPointMake(1.0, 1.0))
            scaleAnimation.toValue = NSValue(CGPoint: CGPointMake(0.5, 0.5))
            scaleAnimation.completionBlock = { _, _ in self.successView.hidden = true }
            
            addAnimation(opacityAnimation, opacityAnimation.property.name, self.successView.layer)
            addAnimation(scaleAnimation, scaleAnimation.property.name, self.successView.layer)
        })
    }
    
    // #pragma mark - UIViewController
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let positionAnimation = POPSpringAnimation(tension: 80, friction: 10, mass: 1)
        positionAnimation.property = POPAnimatableProperty(name: kPOPLayerPositionY)
        positionAnimation.springBounciness = 8.0
        positionAnimation.fromValue = -200
        positionAnimation.toValue = 70.0
        
        let opacityAnimation = POPBasicAnimation()
        opacityAnimation.property = POPAnimatableProperty(name: kPOPLayerOpacity)
        opacityAnimation.toValue = 1.0;
        opacityAnimation.fromValue = 0.0
        
        addAnimation(positionAnimation, positionAnimation.property.name, self.logoImageView.layer)
        addAnimation(opacityAnimation, opacityAnimation.property.name, self.contentView.layer)
    }
    
    func showResetView() {
        self.contentView.hidden = true
        self.resetView.hidden = false
        self.doShakeAnimation()
    }
    
    func restoreView() {
        self.resetView.hidden = true
        self.contentView.hidden = false
        self.numberOfDiscoveries = 0
        self.activityIndicator.startAnimating()
        self.track = nil
        
        self.beaconManager.delegate = self
        self.beaconManager.startRangingBeaconsInRegion(region)
    }
    
    func doShakeAnimation() {
        let shakeAnimation = POPSpringAnimation(tension: 80, friction: 10, mass: 1)
        shakeAnimation.property = POPAnimatableProperty(name: kPOPLayerPositionX)
        shakeAnimation.velocity = 1000
        shakeAnimation.springBounciness = 20.0
        shakeAnimation.completionBlock = { _, _ in
            if !self.resetView.hidden {
                let delay = 1.0 * Double(NSEC_PER_SEC)
                let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
                dispatch_after(time, dispatch_get_main_queue(), {
                    self.doShakeAnimation()
                })
            }
        }
        addAnimation(shakeAnimation, shakeAnimation.property.name, self.resetView.layer)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        (self.locationManager as AnyObject).requestWhenInUseAuthorization?()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.beaconManager.delegate = self
        
        self.region = ESTBeaconRegion(proximityUUID: NSUUID(UUIDString: "B9407F30-F5F8-466E-AFF9-25556B57FE6D"), major: 48556, minor: 44103, identifier: "RegionIdentifier")
        self.beaconManager.startRangingBeaconsInRegion(region)
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        self.beaconManager.stopRangingBeaconsInAllRegions()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        super.prepareForSegue(segue, sender: sender)
        
        if segue.identifier == "presentSearch" {
            let navigationController = segue.destinationViewController as UINavigationController
            let controller = navigationController.viewControllers[0] as SearchViewController
            controller.delegate = self
            navigationController.transitioningDelegate = self
            navigationController.modalPresentationStyle = UIModalPresentationStyle.Custom
            
        }
    }
    
    // #pragma mark - SearchViewControllerDelegate
    
    func searchController(searchController: SearchViewController, didSelectTrack: SearchItem) {
        self.track = didSelectTrack;
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // #pragma mark - ESTBeaconManagerDelegate
    
    func beaconManager(manager: ESTBeaconManager!, didRangeBeacons beacons: [AnyObject]!, inRegion region: ESTBeaconRegion!) {
        println("Found \(beacons.count) beacons in range")
        
        if beacons.count > 0 {
            self.loadingLabel.text = "Beacon in range..."
        } else {
            self.loadingLabel.text = "Searching for beacon..."
            return
        }
        
        let beacon = beacons[0] as ESTBeacon
        
        println(NSString(format:"Distance between beacon and device: %f", beacon.distance.doubleValue))
        
        if (beacon.proximity == CLProximity.Near || beacon.proximity == CLProximity.Immediate) && beacon.distance.doubleValue < 1.5 {
            println(NSString(format:"Beacon imidiate! Distance between beacon and device: %f", beacon.distance.doubleValue))
            if let spotifyURI = track?.url?.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLHostAllowedCharacterSet()) {
                
                if let baseURLString = NSUserDefaults.standardUserDefaults().stringForKey("baseurl_preference") {
                    self.baseURLString = baseURLString
                } else {
                    self.baseURLString = "http://10.0.1.2:3000"
                }
                
                println("Sending spotify URI to server...")
                let url = NSURL(string: NSString(format:  "%@/track/play/%@", self.baseURLString, spotifyURI))
                println("url: %s", url)
                let task = NSURLSession.sharedSession().dataTaskWithURL(url, completionHandler: nil)
                task.resume()
                
                self.loadingLabel.text = "Beacon DETECTED!"
                self.activityIndicator.stopAnimating()
                self.beaconManager.stopRangingBeaconsInAllRegions()
                self.beaconManager.delegate = nil
                
                self.showSuccess()
                self.showResetView()
            }
        }
    }
    
    func beaconManager(manager: ESTBeaconManager!, rangingBeaconsDidFailForRegion region: ESTBeaconRegion!, withError error: NSError!) {
        println("Failed to range beacons: \(error)")
        UIAlertView(title: "Failed", message: "Failed to range beacons", delegate: nil, cancelButtonTitle: "OK")
    }
    
    func beaconManager(manager: ESTBeaconManager!, didDiscoverBeacons beacons: [AnyObject]!, inRegion region: ESTBeaconRegion!) {
        println("Found \(beacons.count) beacons in range")
        if beacons.count > 0 {
            self.loadingLabel.text = NSString(format: "%d beacons in range...", beacons.count);
        } else {
            self.loadingLabel.text = "Searching for beacons..."
        }
    }
    
    func beaconManager(manager: ESTBeaconManager!, didEnterRegion region: ESTBeaconRegion!) {
        println("Did enter region")
    }
    
    // #pragma mark - UIViewControllerTransitioningDelegate
    
    func animationControllerForDismissedController(dismissed: UIViewController!) -> UIViewControllerAnimatedTransitioning! {
        return DismissAnimator()
    }
    
    func animationControllerForPresentedController(presented: UIViewController!, presentingController presenting: UIViewController!, sourceController source: UIViewController!) -> UIViewControllerAnimatedTransitioning! {
        return PresentingAnimator()
    }
    
}

func createSoundEffect() -> SystemSoundID {
    var soundID: SystemSoundID = 0
    let soundURL = NSBundle.mainBundle().URLForResource("status", withExtension: "caf")
    AudioServicesCreateSystemSoundID(soundURL, &soundID)
    return soundID
}
