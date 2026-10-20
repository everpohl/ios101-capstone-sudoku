//
//  SettingsViewController.swift
//  Sudoku
//
//  Created by Everett Matthew Pohl on 10/18/26.
//

import UIKit

class SettingsViewController: UITableViewController {
    @IBOutlet var themeIcon: UISwitch!
    @IBOutlet var highlightPeers: UISwitch!
    @IBOutlet var themeButtons: [UIButton]!
    @IBOutlet var puzzleSource: UISegmentedControl!
    
    @IBOutlet var timerSwitch: UISwitch!
    @IBAction func themeButtonTapped(_ sender: UIButton) {
        let theme = Theme.allCases[sender.tag]
        Theme.current = theme
        view.window?.tintColor = theme.color
        
        UserDefaults.standard.set(sender.tag, forKey: "themeIndex")
        for button in themeButtons {
            button.isSelected = (button == sender)
        }
        
        if themeIcon.isOn {
            changeIcon()
        }
    }
    
    @IBAction func switchedThemeIcon(_ sender: UISwitch) {
        UserDefaults.standard.set(sender.isOn, forKey: "themeIcons")
        changeIcon()
    }
    
    func changeIcon() {
        if themeIcon.isOn {
            UIApplication.shared.setAlternateIconName("Sudoku-\(Theme.current.rawValue.capitalized)")
        } else {
            UIApplication.shared.setAlternateIconName(nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        for button in themeButtons {
            button.layer.cornerRadius = button.frame.width/2
        }
        
        let themeIndex = UserDefaults.standard.integer(forKey: "themeIndex")
        themeButtons.first { $0.tag == themeIndex }?.isSelected = true
        
        themeIcon.isOn = UserDefaults.standard.bool(forKey: "themeIcons")
    }
    
    @IBAction func togglePeers(_ sender: UISwitch) {
        UserDefaults.standard.set(highlightPeers.isOn,forKey: "peers")
    }
    
    @IBAction func toggleTimer(_ sender: UISwitch) {
        UserDefaults.standard.set(sender.isOn, forKey: "timer")
    }
    
    @IBAction func switchSource(_ sender: UISegmentedControl) {
        if (puzzleSource.selectedSegmentIndex == 0) {
            UserDefaults.standard.set(true, forKey: "api")
        } else {
            UserDefaults.standard.set(false, forKey: "api")
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        tableView.deselectRow(at: indexPath, animated: true)
        if (indexPath[1] == 1) {
            themeIcon.setOn(!themeIcon.isOn, animated: true)
            switchedThemeIcon(themeIcon)
        } else if (indexPath[1] == 2) {
            highlightPeers.setOn(!highlightPeers.isOn, animated: true)
            togglePeers(highlightPeers)
        } else if (indexPath[1] == 3) {
            timerSwitch.setOn(!timerSwitch.isOn, animated: true)
            toggleTimer(timerSwitch)
        }
    }
}
