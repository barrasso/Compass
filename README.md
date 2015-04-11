# Compass
Compass lets you find other device locations in real time using iBeacons, Cisco CMX, GPS and OpenDaylight



## Requirements
* Xcode 6.2
* iOS 8.0+



### User Registration
*Note: A single device cannot be registered with multiple UserIDs. However, one UserID may register multiple devices.*



#### Signup Process
1. User succesfully creates a username using `LoginViewController`

2. A container with `"resourceID":"newUserID"` is created under `InCSE1/UserAE/` 

3. A container with `"resourceID":"deviceMACAddress"` is created under `InCSE1/UserAE/newUserID/` and `InCSE1/LocationAE/Things/`

4. Four containers with resourceIDs: `LocBeacon`, `LocCMX`, `LocGPS`, and `AccuracyFlag` are created under `InCSE1/LocationAE/Things/deviceMACAddress/`


