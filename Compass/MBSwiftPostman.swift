//
//  MBSwiftPostman.swift
//  Compass
//
//  Created by Mark on 2/27/15.
//  Copyright (c) 2015 MEB. All rights reserved.
//

import Foundation

class MBSwiftPostman {
    
    // MARK: New User POST Functions
    
    // all new user functions nested
    func createNewUserContainer() {
        
        // set input method
        let httpMethod = "POST"
        
        let userID = PFUser.currentUser().username
        
        // use this url to create new user ID
        let urlAsString = "http://52.10.62.166:8282/InCSE1/MarkUserAE/?from=http:52.10.62.166:10000&requestIdentifier=12345"
        
        // default JSON payload
        var params: [NSString : AnyObject] =
        [
            "from":"http:localhost:10000",
            "requestIdentifier":"12345",
            "resourceType":"container",
            "content": [
                "labels":"",
                "resourceName":userID,
            ]
        ]
        
        // url request properties
        let url = NSURL(string: urlAsString)
        let cachePolicy = NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData
        var err: NSError?
        
        // config request with timeout
        let urlRequest = NSMutableURLRequest(URL: url!, cachePolicy: cachePolicy, timeoutInterval: 15.0)
        urlRequest.HTTPMethod = httpMethod
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.addValue("application/json", forHTTPHeaderField: "Accept")
        urlRequest.addValue("Basic YWRtaW46YWRtaW4=", forHTTPHeaderField: "Authorization")
        urlRequest.HTTPBody = NSJSONSerialization.dataWithJSONObject(params, options: nil, error: &err)
        
        // init queue
        let queue = NSOperationQueue()
        
        // create connection on a new thread for request
        NSURLConnection.sendAsynchronousRequest(urlRequest, queue: queue) { (reponse: NSURLResponse!, data: NSData!, error: NSError!) -> Void in
            
            // deserialize json object
            let json = JSON(data: data)
            println("received response: \(json)")
            println("\n-------------------------------\n")
            
            self.createUUIDContainerUserAE()
            
        } // end url block
    }
    
    func createUUIDContainerUserAE() {
        
        // set input method
        let httpMethod = "POST"
        
        let userID = PFUser.currentUser().username
        let uuid = UIDevice.currentDevice().identifierForVendor.UUIDString
        
        // use this url to create new UUID
        let urlAsString = "http://52.10.62.166:8282/InCSE1/MarkUserAE/"+userID+"/?from=http:52.10.62.166:10000&requestIdentifier=12345"
        
        // JSON payload
        var params: [NSString : AnyObject] =
        [
            "from":"http:localhost:10000",
            "requestIdentifier":"12345",
            "resourceType":"container",
            "content": [
                "labels":"",
                "resourceName":uuid,
            ]
        ]
        
        // url request properties
        let url = NSURL(string: urlAsString)
        let cachePolicy = NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData
        var err: NSError?
        
        // config request with timeout
        let urlRequest = NSMutableURLRequest(URL: url!, cachePolicy: cachePolicy, timeoutInterval: 15.0)
        urlRequest.HTTPMethod = httpMethod
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.addValue("application/json", forHTTPHeaderField: "Accept")
        urlRequest.addValue("Basic YWRtaW46YWRtaW4=", forHTTPHeaderField: "Authorization")
        urlRequest.HTTPBody = NSJSONSerialization.dataWithJSONObject(params, options: nil, error: &err)
        
        // init queue
        let queue = NSOperationQueue()
        
        // create connection on a new thread for request
        NSURLConnection.sendAsynchronousRequest(urlRequest, queue: queue) { (reponse: NSURLResponse!, data: NSData!, error: NSError!) -> Void in
            
            // deserialize json object
            let json = JSON(data: data)
            println("received response: \(json)")
            println("\n-------------------------------\n")
            
            self.createUUIDContainerLocationAE()
            
        } // end url block
    }
    
    func createUUIDContainerLocationAE() {
        
        // set input method
        let httpMethod = "POST"
        
        let uuid = UIDevice.currentDevice().identifierForVendor.UUIDString
        
        // use this url to create new UUID
        let urlAsString = "http://52.10.62.166:8282/InCSE1/MarkLocationAE/Things/?from=http:52.10.62.166:10000&requestIdentifier=12345"
        
        // JSON payload
        var params: [NSString : AnyObject] =
        [
            "from":"http:localhost:10000",
            "requestIdentifier":"12345",
            "resourceType":"container",
            "content": [
                "labels":"",
                "resourceName":uuid,
            ]
        ]
        
        // url request properties
        let url = NSURL(string: urlAsString)
        let cachePolicy = NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData
        var err: NSError?
        
        // config request with timeout
        let urlRequest = NSMutableURLRequest(URL: url!, cachePolicy: cachePolicy, timeoutInterval: 15.0)
        urlRequest.HTTPMethod = httpMethod
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.addValue("application/json", forHTTPHeaderField: "Accept")
        urlRequest.addValue("Basic YWRtaW46YWRtaW4=", forHTTPHeaderField: "Authorization")
        urlRequest.HTTPBody = NSJSONSerialization.dataWithJSONObject(params, options: nil, error: &err)
        
        // init queue
        let queue = NSOperationQueue()
        
        // create connection on a new thread for request
        NSURLConnection.sendAsynchronousRequest(urlRequest, queue: queue) { (reponse: NSURLResponse!, data: NSData!, error: NSError!) -> Void in
            
            // deserialize json object
            let json = JSON(data: data)
            println("received response: \(json)")
            println("\n-------------------------------\n")
            
            self.createLocBeaconContainer()
            
        } // end url block
    }
    
    func createLocBeaconContainer() {
        
        // set input method
        let httpMethod = "POST"
        
        let uuid = UIDevice.currentDevice().identifierForVendor.UUIDString
        
        // use this url to create new UUID
        let urlAsString = "http://52.10.62.166:8282/InCSE1/MarkLocationAE/Things/"+uuid+"/?from=http:52.10.62.166:10000&requestIdentifier=12345"
        
        // JSON payload
        var params: [NSString : AnyObject] =
        [
            "from":"http:localhost:10000",
            "requestIdentifier":"12345",
            "resourceType":"container",
            "content": [
                "labels":"",
                "resourceName":"LocBeacon",
            ]
        ]
        
        // url request properties
        let url = NSURL(string: urlAsString)
        let cachePolicy = NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData
        var err: NSError?
        
        // config request with timeout
        let urlRequest = NSMutableURLRequest(URL: url!, cachePolicy: cachePolicy, timeoutInterval: 15.0)
        urlRequest.HTTPMethod = httpMethod
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.addValue("application/json", forHTTPHeaderField: "Accept")
        urlRequest.addValue("Basic YWRtaW46YWRtaW4=", forHTTPHeaderField: "Authorization")
        urlRequest.HTTPBody = NSJSONSerialization.dataWithJSONObject(params, options: nil, error: &err)
        
        // init queue
        let queue = NSOperationQueue()
        
        // create connection on a new thread for request
        NSURLConnection.sendAsynchronousRequest(urlRequest, queue: queue) { (reponse: NSURLResponse!, data: NSData!, error: NSError!) -> Void in
            
            // deserialize json object
            let json = JSON(data: data)
            println("received response: \(json)")
            println("\n-------------------------------\n")
            
            self.createLocCMXContainer()
            
        } // end url block
    }
    
    func createLocCMXContainer() {
        
        // set input method
        let httpMethod = "POST"
        
        let uuid = UIDevice.currentDevice().identifierForVendor.UUIDString
        
        // use this url to create new UUID
        let urlAsString = "http://52.10.62.166:8282/InCSE1/MarkLocationAE/Things/"+uuid+"/?from=http:52.10.62.166:10000&requestIdentifier=12345"
        
        // JSON payload
        var params: [NSString : AnyObject] =
        [
            "from":"http:localhost:10000",
            "requestIdentifier":"12345",
            "resourceType":"container",
            "content": [
                "labels":"",
                "resourceName":"LocCMX",
            ]
        ]
        
        // url request properties
        let url = NSURL(string: urlAsString)
        let cachePolicy = NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData
        var err: NSError?
        
        // config request with timeout
        let urlRequest = NSMutableURLRequest(URL: url!, cachePolicy: cachePolicy, timeoutInterval: 15.0)
        urlRequest.HTTPMethod = httpMethod
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.addValue("application/json", forHTTPHeaderField: "Accept")
        urlRequest.addValue("Basic YWRtaW46YWRtaW4=", forHTTPHeaderField: "Authorization")
        urlRequest.HTTPBody = NSJSONSerialization.dataWithJSONObject(params, options: nil, error: &err)
        
        // init queue
        let queue = NSOperationQueue()
        
        // create connection on a new thread for request
        NSURLConnection.sendAsynchronousRequest(urlRequest, queue: queue) { (reponse: NSURLResponse!, data: NSData!, error: NSError!) -> Void in
            
            // deserialize json object
            let json = JSON(data: data)
            println("received response: \(json)")
            println("\n-------------------------------\n")
            
            self.createLocGPSContainer()
            
        } // end url block
    }
    
    func createLocGPSContainer() {
    
        // set input method
        let httpMethod = "POST"
        
        let uuid = UIDevice.currentDevice().identifierForVendor.UUIDString
        
        // use this url to create new UUID
        let urlAsString = "http://52.10.62.166:8282/InCSE1/MarkLocationAE/Things/"+uuid+"/?from=http:52.10.62.166:10000&requestIdentifier=12345"
        
        // JSON payload
        var params: [NSString : AnyObject] =
        [
            "from":"http:localhost:10000",
            "requestIdentifier":"12345",
            "resourceType":"container",
            "content": [
                "labels":"",
                "resourceName":"LocGPS",
            ]
        ]
        
        // url request properties
        let url = NSURL(string: urlAsString)
        let cachePolicy = NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData
        var err: NSError?
        
        // config request with timeout
        let urlRequest = NSMutableURLRequest(URL: url!, cachePolicy: cachePolicy, timeoutInterval: 15.0)
        urlRequest.HTTPMethod = httpMethod
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.addValue("application/json", forHTTPHeaderField: "Accept")
        urlRequest.addValue("Basic YWRtaW46YWRtaW4=", forHTTPHeaderField: "Authorization")
        urlRequest.HTTPBody = NSJSONSerialization.dataWithJSONObject(params, options: nil, error: &err)
        
        // init queue
        let queue = NSOperationQueue()
        
        // create connection on a new thread for request
        NSURLConnection.sendAsynchronousRequest(urlRequest, queue: queue) { (reponse: NSURLResponse!, data: NSData!, error: NSError!) -> Void in
            
            // deserialize json object
            let json = JSON(data: data)
            println("received response: \(json)")
            println("\n-------------------------------\n")
            
            self.createAccuracyFlagContainer()
            
        } // end url block
    }
    
    func createAccuracyFlagContainer() {
        // set input method
        let httpMethod = "POST"
        
        let uuid = UIDevice.currentDevice().identifierForVendor.UUIDString
        
        // use this url to create new UUID
        let urlAsString = "http://52.10.62.166:8282/InCSE1/MarkLocationAE/Things/"+uuid+"/?from=http:52.10.62.166:10000&requestIdentifier=12345"
        
        // JSON payload
        var params: [NSString : AnyObject] =
        [
            "from":"http:localhost:10000",
            "requestIdentifier":"12345",
            "resourceType":"container",
            "content": [
                "labels":"000",
                "resourceName":"AccuracyFlag",
            ]
        ]
        
        // url request properties
        let url = NSURL(string: urlAsString)
        let cachePolicy = NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData
        var err: NSError?
        
        // config request with timeout
        let urlRequest = NSMutableURLRequest(URL: url!, cachePolicy: cachePolicy, timeoutInterval: 15.0)
        urlRequest.HTTPMethod = httpMethod
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.addValue("application/json", forHTTPHeaderField: "Accept")
        urlRequest.addValue("Basic YWRtaW46YWRtaW4=", forHTTPHeaderField: "Authorization")
        urlRequest.HTTPBody = NSJSONSerialization.dataWithJSONObject(params, options: nil, error: &err)
        
        // init queue
        let queue = NSOperationQueue()
        
        // create connection on a new thread for request
        NSURLConnection.sendAsynchronousRequest(urlRequest, queue: queue) { (reponse: NSURLResponse!, data: NSData!, error: NSError!) -> Void in
            
            // deserialize json object
            let json = JSON(data: data)
            println("received response: \(json)")
            println("\n-------------------------------\n")
            
        } // end url block
    }
    
    
    
    
    
    
    
    
    
    // MARK: LocationAE POST Functions
    
    func createContentInstanceWith(beaconID: String) {
        
        // set input method
        let httpMethod = "POST"
        
        // use this url to create contentInstance
        let urlAsString = "http://52.10.62.166:8282/InCSE1/MarkLocationAE/Things/MACAddrOfPhone/LocBeacon/BeaconID?from=http:52.10.62.166:10000&requestIdentifier=12345"
        
        /* use this json payload to create content instances */
        var params: [NSString : AnyObject] =
        [
            "from":"http:localhost:10000",
            "requestIdentifier":"12345",
            "resourceType":"contentInstance",
            "content": [
                "resourceName":"",
                "contentInfo":"ID1",
                "content":beaconID,
            ]
        ]
        
        // url request properties
        let url = NSURL(string: urlAsString)
        let cachePolicy = NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData
        var err: NSError?
        
        // config request with timeout
        let urlRequest = NSMutableURLRequest(URL: url!, cachePolicy: cachePolicy, timeoutInterval: 15.0)
        urlRequest.HTTPMethod = httpMethod
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.addValue("application/json", forHTTPHeaderField: "Accept")
        urlRequest.addValue("Basic YWRtaW46YWRtaW4=", forHTTPHeaderField: "Authorization")
        urlRequest.HTTPBody = NSJSONSerialization.dataWithJSONObject(params, options: nil, error: &err)
        
        // init queue
        let queue = NSOperationQueue()
        
        // create connection on a new thread for request
        NSURLConnection.sendAsynchronousRequest(urlRequest, queue: queue) { (reponse: NSURLResponse!, data: NSData!, error: NSError!) -> Void in
            
            // deserialize json object
            let json = JSON(data: data)
            println("received response: \(json)")
            println("\n-------------------------------\n")
            
        } // end url block
    }
}
