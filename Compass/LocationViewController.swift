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
    @IBOutlet var positionLabel: UILabel!
    
    var location: ESTLocation?
    private var manager: ESTIndoorLocationManager!
    
    let colors = [
        48808: UIColor(red: 84/255, green: 77/255, blue: 160/255, alpha: 1),
        10869: UIColor(red: 142/255, green: 212/255, blue: 220/255, alpha: 1),
        32129: UIColor(red: 162/255, green: 213/255, blue: 181/255, alpha: 1)
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.loadLocationFromJSON()
        
        // init indoor manager
        self.manager = ESTIndoorLocationManager()
        self.manager.delegate = self
        
        // start drawing location
        self.indoorLocationView.drawLocation(self.location)
        self.manager.startIndoorLocation(self.location)
        
        // disable rotation
        self.indoorLocationView.rotateOnPositionUpdate = false
        
        let flagView = UIImageView(image: UIImage(named: "user_marker.png"))
        self.indoorLocationView.drawObject(flagView, withPosition: ESTPoint(x: 1.0, y: 1.0))
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.manager.stopIndoorLocation()
    }
    
    func loadLocationFromJSON() {
        let bundle = NSBundle.mainBundle()
        let path = bundle.pathForResource("location", ofType: "json")
        let content = NSString(contentsOfFile: path!, encoding: NSUTF8StringEncoding, error: nil) as! String
        
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
    
    // MARK: ESTIndoorLocationManager delegate
    
    func indoorLocationManager(manager: ESTIndoorLocationManager!, didUpdatePosition position: ESTOrientedPoint!, inLocation location: ESTLocation!) {
        
        // user's position inside room
        self.positionLabel.text = NSString(format: "x: %.2f   y: %.2f    α: %.2f",
            position.x,
            position.y,
            position.orientation) as String
        
        // keep updating user location
        self.indoorLocationView.updatePosition(position)
    }
    
    func indoorLocationManager(manager: ESTIndoorLocationManager!, didFailToUpdatePositionWithError error: NSError!) {
        
        self.positionLabel.text = "It seems that you are outside the location."
        //NSLog(error.localizedDescription)
    }
}
