//
//  LocationViewController.swift
//  Compass
//
//  Created by Mark on 3/31/15.
//  Copyright (c) 2015 MEB. All rights reserved.
//

import UIKit

class LocationViewController: UIViewController, ESTIndoorLocationManagerDelegate {
    
    @IBOutlet var indoorLocationView: ESTIndoorLocationView!
    @IBOutlet var showTraceSwitch: UISwitch!
    @IBOutlet var rotateOnUpdateSwitch: UISwitch!
    @IBOutlet var positionLabel: UILabel!
    
    var location: ESTLocation?
    private var manager: ESTIndoorLocationManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.loadLocationFromJSON()
        
        self.manager = ESTIndoorLocationManager()
        self.manager.delegate = self
        
        self.indoorLocationView.drawLocation(self.location)
        self.manager.startIndoorLocation(self.location)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.manager.stopIndoorLocation()
    }
    
    func loadLocationFromJSON() {
        let bundle = NSBundle.mainBundle()
        let path = bundle.pathForResource("location", ofType: "json")
        let content = NSString(contentsOfFile: path!, encoding: NSUTF8StringEncoding, error: nil) as String
        
        let indoorLocation = ESTLocationBuilder.parseFromJSON(content)
        
        self.location = indoorLocation
        self.title = indoorLocation.name
    }
    
    // MARK: UISwitch events
    
    @IBAction func showTraceSwitchChanged() {
        self.indoorLocationView.clearTrace()
        self.indoorLocationView.traceColor = UIColor.blueColor()
        self.indoorLocationView.showTrace = self.showTraceSwitch.on
    }
    
    @IBAction func rotateOnUpdateSwitchChanged() {
        self.indoorLocationView.rotateOnPositionUpdate = self.rotateOnUpdateSwitch.on
    }
    
    // MARK: ESTIndoorLocationManager delegate
    
    func indoorLocationManager(manager: ESTIndoorLocationManager!, didUpdatePosition position: ESTOrientedPoint!, inLocation location: ESTLocation!) {
        
        self.positionLabel.text = NSString(format: "x: %.2f   y: %.2f    α: %.2f",
            position.x,
            position.y,
            position.orientation)
        
        self.indoorLocationView.updatePosition(position)
    }
    
    func indoorLocationManager(manager: ESTIndoorLocationManager!, didFailToUpdatePositionWithError error: NSError!) {
        
        self.positionLabel.text = "It seems you are outside the location."
        //NSLog(error.localizedDescription)
    }
}
