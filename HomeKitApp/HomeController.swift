//
//  HomeController.swift
//  HomeKitApp
//
//  Created by Jason Cheung on 2016-12-01.
//  Copyright © 2016 Jason Cheung. All rights reserved.
//

import UIKit
import HomeKit

class HomeController: UITableViewController, HMHomeManagerDelegate {

    let homeManager = HMHomeManager()
    
    let cellIdentifier = "homeId"
    let showRoomsSegue = "showRoomsSegue"
    var lastSelectedIndexRow = 0

    // MARK: - View Controller and Custom
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        homeManager.delegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Homes"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == showRoomsSegue) {
            let destination = segue.destination as! RoomController
            destination.selectedHome = homeManager.homes[lastSelectedIndexRow]
        }
    }
    
    func updateControllerWithHome(_ home: HMHome) {
        /*
        if let room = home.rooms.first as HMRoom? {
            activeRoom = room
            title = room.name + " Devices"
        }
 */
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
        
        if let home = homeManager.primaryHome {
            print("Primary home existed")
        } else {
            print("No existing home detected")
            initialHomeSetup()
            
        }
        
        /*
        // Check if we have a home already
        if let home = homeManager.primaryHome {
            activeHome = home
            updateControllerWithHome(home)
        } else {    // else set it up
            initialHomeSetup()
        }
        tableView.reloadData()*/
    }
    
    
    
    // MARK: - Table Delegate
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return homeManager.homes.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as UITableViewCell?
        
        let home = homeManager.homes[indexPath.row]
        cell?.textLabel?.text = home.name
        
        return (cell != nil) ? cell! : UITableViewCell()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        lastSelectedIndexRow = indexPath.row
        self.performSegue(withIdentifier: showRoomsSegue, sender: self)
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
