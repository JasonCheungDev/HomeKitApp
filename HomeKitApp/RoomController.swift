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
    
    private let homeManager = HMHomeManager()
    private let cellIdentifier = "roomId"
    private let showAccessorySegue = "showAccessoriesSegue"
    private var lastSelectedIndexRow = 0
    
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
            let destination = segue.destination as! ViewController
            destination.selectedHome = selectedHome
            destination.selectedRoom = selectedHome.rooms[lastSelectedIndexRow]
        }
    }
    
    @IBAction func onAddClick(_ sender: AnyObject) {
        displayAddRoomAlert()
    }
    
    func displayAddRoomAlert() {
        //1. Create the alert controller.
        let alert = UIAlertController(title: "Add Room", message: "Enter a name", preferredStyle: .alert)
        
        //2. Add the text field. You can configure it however you need.
        alert.addTextField { (textField) in
            // textField.text = "Room name"
        }
        
        // 3. Grab the value from the text field, and print it when the user clicks OK.
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0] // Force unwrapping because we know it exists.
            print("Text field: \(textField?.text)")
            self.addRoom((textField?.text)!)
            }))
        
        // 4. Present the alert.
        self.present(alert, animated: true, completion: nil)
    }
    
    func addRoom(_ name : String) {
        selectedHome.addRoom(withName: name, completionHandler: { (newRoom, error) in
            
            // Check for error
            if error != nil {
                print("Adding room error: \(error?.localizedDescription)")
                return
            }
            
            // Update table
            self.tableView.reloadData()
        })
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
    }
    
    
    
    // MARK: - Table Delegate
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return selectedHome.rooms.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as UITableViewCell?
        
        let room = selectedHome.rooms[indexPath.row]
        cell?.textLabel?.text = room.name
        
        return (cell != nil) ? cell! : UITableViewCell()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        lastSelectedIndexRow = indexPath.row
        self.performSegue(withIdentifier: showAccessorySegue, sender: self)
    }


}
