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
    var selectedHome: HMHome!
    var selectedRoom: HMRoom!
    
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
        title = selectedRoom.name + " Accessories"
        tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == showServicesSegue) {
            let destination = segue.destination as! AccessoryTableViewController
            destination.accessory = selectedRoom.accessories[lastSelectedIndexRow]
        } else if (segue.identifier == "showDiscoverySegue") {
            let destination = segue.destination as! DiscoveryTableViewController
            destination.selectedHome = selectedHome
            destination.selectedRoom = selectedRoom
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
        // ...
    }
    
    
    
    // MARK: - Table Delegate 
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return selectedRoom.accessories.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as UITableViewCell?
        let accessory = selectedRoom.accessories[indexPath.row] as HMAccessory
        cell?.textLabel?.text = accessory.name
        
        // Show how many services this accessory has. Ignore information service (additional info we can show if you want)
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
    
}

