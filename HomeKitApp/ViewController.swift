//
//  ViewController.swift
//  HomeKitApp
//
//  Created by Jason Cheung on 2016-11-21.
//  Copyright © 2016 Jason Cheung. All rights reserved.
//

import UIKit
import HomeKit

class ViewController: UITableViewController, HMHomeManagerDelegate {

    let homeManager = HMHomeManager()
    var activeHome: HMHome?
    var activeRoom: HMRoom?
    
    let cellIdentifier = "deviceId"
    var lastSelectedIndexRow = 0
    
    let showServicesSegue = "showServicesSegue"
    
    // MARK: - View Controller and Custom
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        homeManager.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == showServicesSegue) {
            let destination = segue.destination as! AccessoryTableViewController
            if let accessories = activeRoom?.accessories {
                destination.accessory = accessories[lastSelectedIndexRow] as HMAccessory?
            }
        }
    }
    
    func updateControllerWithHome(_ home: HMHome) {
        if let room = home.rooms.first as HMRoom? {
            activeRoom = room
            title = room.name + " Devices"
        }
    }

    
    
    // MARK: - Home Delegate 
    
    // Homes are not loaded right away; Monitor the delegate so we catch the loaded signal
    func homeManager(_ manager: HMHomeManager, didAdd home: HMHome) {
        // not sure why this is empty
    }
    
    func homeManager(_ manager: HMHomeManager, didRemove home: HMHome) {
        // not sure why this is empty
    }
    
    func homeManagerDidUpdatePrimaryHome(_ manager: HMHomeManager) {
        // not sure why this is empty
    }
    
    func homeManagerDidUpdateHomes(_ manager: HMHomeManager) {
        // Check if we have a home already
        if let home = homeManager.primaryHome {
            activeHome = home
            updateControllerWithHome(home)
        } else {    // else set it up
            initialHomeSetup()
        }
        tableView.reloadData()
    }
    
    
    
    // MARK: - Table Delegate 
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let accessories = activeRoom?.accessories  {
            return accessories.count
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as UITableViewCell?
        let accessory = activeRoom!.accessories[indexPath.row] as HMAccessory
        cell?.textLabel?.text = accessory.name
        
        // ignore information service (additional info we can show if you want) 
        cell?.detailTextLabel?.text = "\(accessory.services.count - 1) service(s)"
        
        return (cell != nil) ? cell! : UITableViewCell()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        lastSelectedIndexRow = indexPath.row
        self.performSegue(withIdentifier: showServicesSegue, sender: self)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        /*if(editingStyle == .delete){
            accessory.remove(at: indexPath.row)
            TableView.deleteRows(at: [indexPath], with: .fade)
        } else if (editingStyle == .edit) {
            
        }
        
        let acc = activeRoom!.accessories[indexPath.row] as HMAccessory
        activeRoom!.remove
        
        let accessories =
        
        var index = 0
        for item in accessories {
            if item.name == accessory.name {
                accessories.remove(at: index)
                break; // found and removed
            }
            index += 1
        }
        tableView.reloadData()
        */
    }
    
    
    // MARK: - Setup 
    
    // Create primary home if it doesn't exist yet
    private func initialHomeSetup() {
        
        // Create a new test home and room, and then assign it as our primary home.
        homeManager.addHome(withName: "Test Home", completionHandler: { (home, error) in
            
            // Check for errors
            if error != nil {
                print("Initial home creation error: \(error?.localizedDescription)")
                return
            }
            
            // Wrap to determine if any error occurred ... (guess)
            if let discoveredHome = home {
                
                // Add a new (non-default) room to our new home
                discoveredHome.addRoom(withName: "Test Room", completionHandler: { (room, error) in
                    
                    // Check for errors
                    if error != nil {
                        print("Initial room creation error: \(error?.localizedDescription)")
                        return
                    } else {
                        self.updateControllerWithHome(discoveredHome)   // Set the active room for this controller
                    }
                    
                })
                
                // Assign this home as our primary home 
                self.homeManager.updatePrimaryHome(discoveredHome, completionHandler: { (error) in

                    // Check for errors
                    if error != nil {
                        print("Reassigning primary home error: \(error?.localizedDescription)")
                        return
                    }
                    
                })
                
            } else {
                print("Home creation error")
            }
        })
    }


}

