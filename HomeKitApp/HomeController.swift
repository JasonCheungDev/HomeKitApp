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

    private let homeManager = HMHomeManager()
    private let cellIdentifier = "homeId"
    private let showRoomsSegue = "showRoomsSegue"
    private var lastSelectedIndexRow = 0

    
    
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
    
    @IBAction func onAddClick(_ sender: AnyObject) {
        displayAddHomeAlert()
    }
    
    func displayAddHomeAlert() {
        //1. Create the alert controller.
        let alert = UIAlertController(title: "Add Home", message: "Enter a name", preferredStyle: .alert)
        
        //2. Add the text field. You can configure it however you need.
        alert.addTextField { (textField) in
            // textField.text = "Building name"
        }
        
        // 3. Grab the value from the text field, and print it when the user clicks OK.
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0] // Force unwrapping because we know it exists.
                print("Text field: \(textField?.text)")
                self.addHome((textField?.text)!)
            }))
        
        // 4. Present the alert.
        self.present(alert, animated: true, completion: nil)
    }
    
    func addHome(_ name : String) {
        homeManager.addHome(withName: name, completionHandler: { (newHome, error) in
            
            // Check for error 
            if error != nil {
                print("Adding home error: \(error?.localizedDescription)")
                return
            }
            
            // Update table 
            self.tableView.reloadData()
            
            // Assign this home as our primary home
            self.homeManager.updatePrimaryHome(newHome!, completionHandler: { (error) in
                
                // Check for errors
                if error != nil {
                    print("Reassigning primary home error: \(error?.localizedDescription)")
                    return
                }
                
            })
        })
    }
    
    
    
    // MARK: - Home Delegate
    
    // Homes are not loaded right away; Monitor the delegate so we catch the loaded signal
    func homeManager(_ manager: HMHomeManager, didAdd home: HMHome) {
    }
    
    func homeManager(_ manager: HMHomeManager, didRemove home: HMHome) {
    }
    
    func homeManagerDidUpdatePrimaryHome(_ manager: HMHomeManager) {
    }
    
    func homeManagerDidUpdateHomes(_ manager: HMHomeManager) {
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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        // don't have a race condition
        lastSelectedIndexRow = indexPath.row
        self.performSegue(withIdentifier: showRoomsSegue, sender: self)
    }

}
