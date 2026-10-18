//
//  SettingsViewController.swift
//  Sudoku
//
//  Created by Everett Matthew Pohl on 10/18/26.
//

import UIKit

class SettingsViewController: UITableViewController {
    @IBOutlet var themeButtons: [UIButton]!
    
    
    @IBAction func themeButtonTapped(_ sender: UIButton) {
        let theme = Theme.allCases[sender.tag]
        Theme.current = theme
        view.window?.tintColor = theme.color   // tab bar updates immediately
        
        //UserDefaults.standard.set(sender.tag, forKey: "themeIndex")
        for button in themeButtons {
            button.isSelected = (button == sender)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        for button in themeButtons {
//            button.setImage(UIImage(systemName: "checkmark"), for: .selected)
//            button.tintColor = .white
//            let config = UIImage.SymbolConfiguration(scale: .small)
//            button.setPreferredSymbolConfiguration(config, forImageIn: .selected)
            button.layer.cornerRadius = button.frame.width/2
        }
        
        let themeIndex = UserDefaults.standard.integer(forKey: "themeIndex")
        themeButtons.first { $0.tag == themeIndex }?.isSelected = true
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

//    override func numberOfSections(in tableView: UITableView) -> Int {
//        // #warning Incomplete implementation, return the number of sections
//        return 2
//    }
//
//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        // #warning Incomplete implementation, return the number of rows
//        return 2
//    }

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
