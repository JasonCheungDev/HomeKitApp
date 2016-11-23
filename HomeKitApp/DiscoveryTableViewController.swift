//
//  DiscoveryTableViewController.swift
//  HomeKitApp
//
//  Created by Jason Cheung on 2016-11-21.
//  Copyright © 2016 Jason Cheung. All rights reserved.
//

import UIKit
import HomeKit

class DiscoveryTableViewController: UITableViewController, HMAccessoryBrowserDelegate {

    let homeManager = HMHomeManager()
    let browser = HMAccessoryBrowser()
    
    var accessories = [HMAccessory]()
    let cellIdentifier = "accessoryId"

    @IBOutlet weak var refreshButton: UIBarButtonItem!
    
    @IBAction func onRefreshClick(_ sender: AnyObject) {
        startSearching()
    }
    
    // MARK: - Class and custom
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        title = "Searching"
        
        // The delegate will inform us about accessory activity (discovered / lost)
        browser.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // Immediately start discovery process
        startSearching()
    }
    
    func startSearching() {
        // Prevent stacking calls 
        refreshButton.isEnabled = false
        
        // start discovery process
        browser.startSearchingForNewAccessories()
        
        // Stop discovery process after 10 seconds to save battery / resources
        Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(DiscoveryTableViewController.stopSearching), userInfo: nil, repeats: false)
    }
    
    func stopSearching() {
        title = "Discovered"
        browser.stopSearchingForNewAccessories()
        refreshButton.isEnabled = true
    }
    
    
    
    // MARK: - Accessory Delegate
    
    // Called when a new accessory is located
    func accessoryBrowser(_ browser: HMAccessoryBrowser, didFindNewAccessory accessory: HMAccessory) {
        accessories.append(accessory)
        tableView.reloadData()
    }
    
    // Called when an accessory has been removed or no longer reachable 
    func accessoryBrowser(_ browser: HMAccessoryBrowser, didRemoveNewAccessory accessory: HMAccessory) {
        var index = 0
        for item in accessories {
            if item.name == accessory.name {
                accessories.remove(at: index)
                break; // found and removed
            }
            index += 1
        }
        tableView.reloadData()
    }		
    
    
    
    // MARK: - Table 
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return accessories.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)!
        let accessory = accessories[(indexPath as NSIndexPath).row] as HMAccessory
        cell.textLabel?.text = accessory.name
        return cell
    }
    
    // Add selected row (accessory) to our room (in our home)
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // Get selected accessory
        let accessory = accessories[(indexPath as NSIndexPath).row] as HMAccessory
        
        // Add to home and room
        if let room = homeManager.primaryHome?.rooms.first as HMRoom? {
            
            // Add accessory to primary home
            homeManager.primaryHome?.addAccessory(accessory, completionHandler: { (error) -> Void in
                
                // Check for errors
                if error != nil {
                    print("Error adding an accessory to home: \(error?.localizedDescription)")
                } else {
                    
                    // Assign accessory to room
                    self.homeManager.primaryHome?.assignAccessory(accessory, to: room, completionHandler: { (error) -> Void in
                        
                        // Check for errors
                        if error != nil {
                            print("Error assign an accessory to room: \(error?.localizedDescription)")
                        } else {
                            
                            // All finished, go back to main view
                            self.navigationController?.popViewController(animated: true)
                        }
                    })
                }
            })
        }
    }

}
