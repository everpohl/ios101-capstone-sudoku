//
//  SettingsViewController.swift
//  Sudoku
//
//  Created by Everett Matthew Pohl on 10/18/26.
//

import UIKit

class SettingsViewController: UITableViewController {
    @IBOutlet var themeIcon: UISwitch!
    @IBOutlet var themeButtons: [UIButton]!
    
    
    @IBAction func themeButtonTapped(_ sender: UIButton) {
        let theme = Theme.allCases[sender.tag]
        Theme.current = theme
        view.window?.tintColor = theme.color   // tab bar updates immediately
        
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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 1. Deselect the row so it doesn't stay gray
        tableView.deselectRow(at: indexPath, animated: true)
        if (indexPath[1] == 1) {
            // Tapping the row doesn't flip the switch on its own, so flip it here first
            themeIcon.setOn(!themeIcon.isOn, animated: true)
            switchedThemeIcon(themeIcon)
        }
    }
}
