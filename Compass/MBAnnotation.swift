//
//  MBAnnotation.swift
//  Compass
//
//  Created by Mark on 3/3/15.
//  Copyright (c) 2015 MEB. All rights reserved.
//

import UIKit
import MapKit

class MBAnnotation: NSObject, MKAnnotation {
    
    var coordinate: CLLocationCoordinate2D = CLLocationCoordinate2DMake(0, 0)
    var title: String!
    var subtitle: String!
    
    init(coordinate: CLLocationCoordinate2D, title: String, subtitle: String) {
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
        super.init()
    }

}
