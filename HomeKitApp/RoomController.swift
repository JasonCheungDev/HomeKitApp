//
//  RoomController.swift
//  HomeKitApp
//
//  Created by Jason Cheung on 2016-12-01.
//  Copyright © 2016 Jason Cheung. All rights reserved.
//

import UIKit
import HomeKit

class RoomController: UITableViewController, HMHomeManagerDelegate {

    var selectedHome : HMHome!
    
    let homeManager = HMHomeManager()
    
    let cellIdentifier = "roomId"
    let showAccessorySegue = "showAccesorySegue"
    var lastSelectedIndexRow = 0
    
    // MARK: - View Controller and Custom
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        homeManager.delegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = (selectedHome.name) + " Rooms"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == showAccessorySegue) {
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
        return selectedHome.accessories.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as UITableViewCell?
        
        let accessory = selectedHome.accessories[indexPath.row]
        cell?.textLabel?.text = accessory.name
        
        return (cell != nil) ? cell! : UITableViewCell()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        lastSelectedIndexRow = indexPath.row
        self.performSegue(withIdentifier: showAccessorySegue, sender: self)
    }


}
