//
//  main.swift
//  swift-libimobiledevice
//
//  Created by Maxime on 07/09/2020.
//  Copyright © 2020 Madrau. All rights reserved.
//

import Cocoa

var i: CInt = 0
var device_list: UnsafeMutablePointer<UnsafeMutablePointer<Int8>?>? = nil

idevice_get_device_list(&device_list, &i)
print("Number of devices: \(i)")

let array = Array(UnsafeBufferPointer(start: device_list, count: Int(i)))

for var device in array {
    let uuid = String(cString: device!)
    
    var dev: idevice_t? = nil
    idevice_new_with_options(&dev, uuid, idevice_options(rawValue: 1 << 2))


    var lockdown: lockdownd_client_t? = nil
    lockdownd_client_new_with_handshake(dev, &lockdown, "idevicepair")

    var name: UnsafeMutablePointer<Int8>? = nil
    lockdownd_get_device_name(lockdown, &name);

    print (" - " + String(cString: name!))

}

idevice_device_list_free(device_list)



