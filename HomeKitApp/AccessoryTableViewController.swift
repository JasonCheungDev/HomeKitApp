//
//  AccessoryTableViewController.swift
//  HomeKitApp
//
//  Created by Jason Cheung on 2016-11-21.
//  Copyright © 2016 Jason Cheung. All rights reserved.
//

import UIKit
import HomeKit

// Shows information about a particular accessory's service 
class AccessoryTableViewController:
    UITableViewController,
    HMAccessoryDelegate,
    UIGestureRecognizerDelegate
{

    var selectedRoom: HMRoom!
    var accessory: HMAccessory?
    private var data = [HMService]()
    private let cellIdentifier = "serviceId"
    
    // MARK: - View controller
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Only handle lightbulb services
        for service in accessory!.services {
            if service.serviceType == HMServiceTypeLightbulb {
                data.append(service as HMService)
            }
        }
        
        accessory?.delegate = self
        
        // Gesture recognition 
        let lpr = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(gestureRecognizer:)))
        lpr.delegate = self
        tableView.addGestureRecognizer(lpr)
    }
    
    func handleLongPress(gestureRecognizer: UILongPressGestureRecognizer) {
        if gestureRecognizer.state != .ended {
            return
        }
        
        let point = gestureRecognizer.location(in: self.tableView)
        let indexPath = self.tableView.indexPathForRow(at: point)
        
        if let index = indexPath {
            // var cell = self.tableView.cellForRow(at: index)
            // do stuff 
            print("Long press at \(index.row)")
        } else {
            print("Could not find index path for long press")
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tableView.reloadData()
    }
    

    
    // MARK: - Accessory Delegate 
    
    func accessory(_ accessory: HMAccessory, service: HMService, didUpdateValueFor characteristic: HMCharacteristic) {
        print("Accessory characteristic has changed! \(characteristic.value)")
        tableView.reloadData()
    }
    
    
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let _ = accessory {
            return data.count
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as UITableViewCell?
        let service = data[(indexPath as NSIndexPath).row] as HMService
        
        for item in service.characteristics {
            let characteristic = item as HMCharacteristic
            print("value \(characteristic.value) : \(characteristic.metadata)")
            
            // Display current service details and listen for changes
            if let metadata = characteristic.metadata as HMCharacteristicMetadata? {
                
                // Bool characteristic
                if metadata.format == HMCharacteristicMetadataFormatBool {
                    
                    // Display if the service is on / off
                    cell?.detailTextLabel?.text = (characteristic.value as! Bool == true) ? "ON" : "OFF"
                
                    // Enable notification for characteristic (monitor state changes - changes processed accessory delegate mark)
                    characteristic.enableNotification(true, completionHandler: { (error) -> Void in
                        if error != nil {
                            print("Error enabling notification for a characteristic: \(error?.localizedDescription)")
                        }
                    })
                    
                // String characteristic
                } else if metadata.format == HMCharacteristicMetadataFormatString {
                    cell?.textLabel?.text = characteristic.value as? String
                }
                
                // ... etc. for other characteristic formats
            }
        }
        
        return (cell != nil) ? cell!: UITableViewCell()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        func serviceUpdatedHandler(error: Error?) -> Void{
            if error != nil {
                print("Error attempting to update the service: \(error?.localizedDescription)")
            }
            self.tableView.reloadData()
        }
        
        let service = data[indexPath.row] as HMService
        
        let foo = service.characteristics
        for chara in foo {
            print("==========")
            print(chara)
            print(chara.description)
            print(chara.characteristicType)
            print(chara.value)
            print(chara.metadata)
            print("Properties:")
            for bar in chara.properties {
                print(bar)
            }
            print("----------")
        }
        
        // Toggle the device service state (on / off)
        let powerStateC = service.characteristics[1] as HMCharacteristic
        let toggleState = (powerStateC.value as! Bool) ? false : true
        powerStateC.writeValue(NSNumber(value: toggleState as Bool), completionHandler: serviceUpdatedHandler)
        
        // Others 
        let brightnessC = service.characteristics[2] as HMCharacteristic
        let currentBrightness = brightnessC.value as! Int
        let newBrightness = ((currentBrightness + 25) > 100) ? 0 : currentBrightness + 25
        brightnessC.writeValue(NSNumber(value: newBrightness as Int), completionHandler: serviceUpdatedHandler)
        
        let hueC = service.characteristics[3] as HMCharacteristic
        let currentHue = hueC.value as! Float
        let newHue = ((currentHue + 30) > 360) ? 0 : currentHue + 30
        hueC.writeValue(NSNumber(value: newHue as Float), completionHandler: serviceUpdatedHandler)

        let saturationC = service.characteristics[4] as HMCharacteristic
        let currentSaturation = saturationC.value as! Float
        let newSaturation = (currentSaturation + 25) > 100 ? 0 : currentSaturation + 25
        saturationC.writeValue(NSNumber(value: newSaturation as Float), completionHandler: serviceUpdatedHandler)
    }
    
}

/* LightBulb service notes 
Characteristics[]
 0 - Name : String
 1 - Power state : Bool (off/on)
 2 - Brightness : Int (0-100)
 3 - Hue : Float (Arcdegrees 0-360)
 4 - Saturation : Float (0-100)
 */
