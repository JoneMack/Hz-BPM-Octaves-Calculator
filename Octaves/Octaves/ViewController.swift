//
//  ViewController.swift
//  Octaves
//
//  Created by 262Hz on 7/4/15.
//  Copyright (c) 2015 262Hz. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate {
    
    let hue: CGFloat = 0.5 // Choose a value between 0 and 1 to determine color scheme of UI.
    
    var noteNamePickerView: UIPickerView!
    var centsOffsetPickerView: UIPickerView!
    
    var noteNames: [String] = ["C", "C♯", "D♭", "D", "D♯", "E♭", "E", "F", "F♯", "G♭", "G", "G♯", "A♭", "A", "A♯", "B♭", "B"]
    var centsOffsetOptions: [Int] = []
    var indexOfZeroCents: Int!
    
    let hzUserDefaultKey = "hz"

    @IBOutlet weak var hzTextField: UITextField!
    @IBOutlet weak var bpmTextField: UITextField!
    @IBOutlet weak var noteNameTextField: UITextField!
    @IBOutlet weak var centsOffsetTextField: UITextField!
    
    @IBOutlet weak var bottomSpaceForNumbersViewContraint: NSLayoutConstraint!
    
    @IBOutlet weak var hzOneUpLabel: UILabel!
    @IBOutlet weak var hzTwoUpLabel: UILabel!
    @IBOutlet weak var hzOneDownLabel: UILabel!
    @IBOutlet weak var hzTwoDownLabel: UILabel!
    
    @IBOutlet weak var bpmOneUpLabel: UILabel!
    @IBOutlet weak var bpmTwoUpLabel: UILabel!
    @IBOutlet weak var bpmOneDownLabel: UILabel!
    @IBOutlet weak var bpmTwoDownLabel: UILabel!
    
    @IBOutlet weak var firstColumnBackgroundView: UIView!
    @IBOutlet weak var secondColumnBackgroundView: UIView!
    @IBOutlet weak var thirdColumnBackgroundView: UIView!
    
    //MARK:- UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        populateCentsOffsetOptionsArray()
        
        setupUI()
        
        setHzFromUserDefaults()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    //MARK:- ViewController
    
    func populateCentsOffsetOptionsArray() {
        for i in -50...50 {
            centsOffsetOptions.append(i)
        }
        
        indexOfZeroCents = centsOffsetOptions.indexOf(0)
    }
    
    /**

     Set up color scheme, set placeholder values, clear labels, create picker views, and add gesture recognizers for swipe up/down.
     
     */
    func setupUI() {
        // Set up the color scheme.
        let textFieldTintColor = UIColor(hue: hue, saturation: 1.0, brightness: 0.7, alpha: 1.0)
        hzTextField.tintColor = textFieldTintColor
        bpmTextField.tintColor = textFieldTintColor
        noteNameTextField.tintColor = textFieldTintColor
        centsOffsetTextField.tintColor = textFieldTintColor
        
        firstColumnBackgroundView.backgroundColor = UIColor(hue: hue, saturation: 1.0, brightness: 0.6, alpha: 1.0)
        secondColumnBackgroundView.backgroundColor = UIColor(hue: hue, saturation: 1.0, brightness: 0.5, alpha: 1.0)
        thirdColumnBackgroundView.backgroundColor = UIColor(hue: hue, saturation: 1.0, brightness: 0.4, alpha: 1.0)
        
        let placeholderColor = UIColor(white: 1.0, alpha: 0.5)
        
        // Placeholder values are based on 262Hz. Follow me on Instagram, SoundCloud, and other social media @262Hz
        hzTextField.attributedPlaceholder = NSAttributedString(string: "262.00", attributes: [NSForegroundColorAttributeName: placeholderColor])
        bpmTextField.attributedPlaceholder = NSAttributedString(string: "121.81", attributes: [NSForegroundColorAttributeName: placeholderColor])
        noteNameTextField.attributedPlaceholder = NSAttributedString(string: "C", attributes: [NSForegroundColorAttributeName: placeholderColor])
        centsOffsetTextField.attributedPlaceholder = NSAttributedString(string: "+2", attributes: [NSForegroundColorAttributeName: placeholderColor])
        
        // Clear labels.
        hzOneUpLabel.text = ""
        hzTwoUpLabel.text = ""
        hzOneDownLabel.text = ""
        hzTwoDownLabel.text = ""
        
        bpmOneUpLabel.text = ""
        bpmTwoUpLabel.text = ""
        bpmOneDownLabel.text = ""
        bpmTwoDownLabel.text = ""
        
        // Create picker views for note names and cents offset options.
        let pickerViewHeight: CGFloat = 216 //162.0, 180.0, or 216.0 – UIPickerView only likes these specific heights.
        let frame = CGRect(x: 0, y: 0, width: view.frame.width, height: pickerViewHeight)
        
        noteNamePickerView = UIPickerView(frame: frame)
        noteNamePickerView.dataSource = self
        noteNamePickerView.delegate = self
        noteNamePickerView.selectRow(0, inComponent: 0, animated: false)
        
        centsOffsetPickerView = UIPickerView(frame: frame)
        centsOffsetPickerView.dataSource = self
        centsOffsetPickerView.delegate = self
        centsOffsetPickerView.selectRow(indexOfZeroCents, inComponent: 0, animated: false)
        
        noteNameTextField.inputView = self.noteNamePickerView
        centsOffsetTextField.inputView = self.centsOffsetPickerView
        
        // Add gesture recognizers for swiping up and down.
        let swipeDownGestureRecognizer = UISwipeGestureRecognizer(target: self, action: "swipeDown")
        swipeDownGestureRecognizer.direction = UISwipeGestureRecognizerDirection.Down
        view.addGestureRecognizer(swipeDownGestureRecognizer)
        
        let swipeUpGestureRecognizer = UISwipeGestureRecognizer(target: self, action: "swipeUp")
        swipeUpGestureRecognizer.direction = UISwipeGestureRecognizerDirection.Up
        view.addGestureRecognizer(swipeUpGestureRecognizer)
    }
    
    func swipeDown() {
        // End editing when user swipes down, causing the keyboard to disappear.
        view.endEditing(false)
    }
    
    func swipeUp() {
        // If no text field is currently being edited when the user swipes up, the Hz text field will become first responder which will trigger the keyboard to appear.
        if false == (hzTextField.isFirstResponder() || bpmTextField.isFirstResponder() || noteNameTextField.isFirstResponder() || centsOffsetTextField.isFirstResponder()) {
            hzTextField.becomeFirstResponder()
        }
    }
    
    func calculateForHz(hz: Double) {
        updateForHz(hz, shouldModifyTextField: false)
        
        let bpm = hzToBPM(hz)
        
        updateForBPM(bpm, shouldModifyTextField: true)
        
        let (noteName, centsOffset) = hzToNoteNameAndCentsOffset(hz)
        
        updateForNoteName(noteName, shouldModifyNoteNamePickerView: true, centsOffSet: centsOffset, shouldMofifyCentsOffsetPickerView: true)
    }
    
    func updateForHz(hz: Double, shouldModifyTextField: Bool) {
        if shouldModifyTextField {
            if hz == 0 {
                hzTextField.text = ""
            } else {
                hzTextField.text = hz.string()
            }
        }
        
        let hzOneUp = hz*2
        let hzTwoUp = hz*4
        let hzOneDown = hz/2
        let hzTwoDown = hz/4
        
        hzOneUpLabel.text = hzOneUp.string()
        hzTwoUpLabel.text = hzTwoUp.string()
        hzOneDownLabel.text = hzOneDown.string()
        hzTwoDownLabel.text = hzTwoDown.string()
        
        saveHzInUserDefaults(hz)
    }
    
    func saveHzInUserDefaults(hz: Double) {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        
        userDefaults.setValue(hz, forKey: hzUserDefaultKey)
        
        userDefaults.synchronize()
    }
    
    func setHzFromUserDefaults() {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        
        let savedHz = userDefaults.valueForKey(hzUserDefaultKey)
        
        if let savedHz = savedHz as? Double {
            hzTextField.text = savedHz.string()
            calculateForHz(savedHz)
        }
    }
    
    func calculateForBPM(bpm: Double) {
        updateForBPM(bpm, shouldModifyTextField: false)
        
        let hz = bpmToHz(bpm)
        
        updateForHz(hz, shouldModifyTextField: true)
        
        let (noteName, centsOffset) = hzToNoteNameAndCentsOffset(hz)
        
        updateForNoteName(noteName, shouldModifyNoteNamePickerView: true, centsOffSet: centsOffset, shouldMofifyCentsOffsetPickerView: true)
    }
    
    func updateForBPM(bpm: Double, shouldModifyTextField: Bool) {
        if shouldModifyTextField {
            if bpm == 0 {
                bpmTextField.text = ""
            } else {
                bpmTextField.text = bpm.string()
            }
        }
        
        let bpmOneUp = bpm*2
        let bpmTwoUp = bpm*4
        let bpmOneDown = bpm/2
        let bpmTwoDown = bpm/4
        
        bpmOneUpLabel.text = bpmOneUp.string()
        bpmTwoUpLabel.text = bpmTwoUp.string()
        bpmOneDownLabel.text = bpmOneDown.string()
        bpmTwoDownLabel.text = bpmTwoDown.string()
    }
    
    func updateForNoteName(noteName: String, shouldModifyNoteNamePickerView: Bool, centsOffSet: Double, shouldMofifyCentsOffsetPickerView: Bool) {
        if noteName == "" {
            noteNameTextField.text = ""
            centsOffsetTextField.text = ""
            return // If note name is blank, no sense in proceeding with calculations.
        }
        
        if shouldModifyNoteNamePickerView {
            let index = noteNames.indexOf(noteName)
            
            noteNamePickerView.selectRow(index!, inComponent: 0, animated: false)
        }
        
        noteNameTextField.text = noteName
        
        let centsOffsetInteger = Int(round(centsOffSet))
        
        if shouldMofifyCentsOffsetPickerView {
            let index = centsOffsetInteger + indexOfZeroCents
            centsOffsetPickerView.selectRow(index, inComponent: 0, animated: false)
        }
        
        var centsOffsetText = ""
        if centsOffsetInteger >= 0 {
            centsOffsetText += "+"
        }
        centsOffsetText += "\(centsOffsetInteger)"
        
        centsOffsetTextField.text = centsOffsetText
    }
    
    func keyboardWillShow(notification: NSNotification) {
        let userInfo = notification.userInfo!
        let keyboardFrame: CGRect = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        let newBottomSpaceValue = keyboardFrame.size.height
        let duration = userInfo[UIKeyboardAnimationDurationUserInfoKey] as! NSTimeInterval
        let animationCurve = UIViewAnimationCurve(rawValue: userInfo[UIKeyboardAnimationCurveUserInfoKey]!.integerValue)!
        let animationOptions = animationCurve.toOptions()
        
        view.layoutIfNeeded()
        
        bottomSpaceForNumbersViewContraint.constant = newBottomSpaceValue
        
        UIView.animateWithDuration(duration, delay: 0, options: animationOptions, animations: {
            self.view.layoutIfNeeded()
        }, completion: nil);
    }
    
    func keyboardWillHide(notification: NSNotification) {
        let userInfo = notification.userInfo!
        let newBottomSpaceValue: CGFloat = 0
        let duration = userInfo[UIKeyboardAnimationDurationUserInfoKey] as! NSTimeInterval
        let animationCurve = UIViewAnimationCurve(rawValue: userInfo[UIKeyboardAnimationCurveUserInfoKey]!.integerValue)!
        let animationOptions = animationCurve.toOptions()
        
        view.layoutIfNeeded()
        
        bottomSpaceForNumbersViewContraint.constant = newBottomSpaceValue
        
        UIView.animateWithDuration(duration, delay: 0, options: animationOptions, animations: {
            self.view.layoutIfNeeded()
            }, completion: nil);
    }
    
    @IBAction func centsOffsetDoubleTapped() {
        // Reset cents offset to 0 when double tapped.
        let noteNameIndex = noteNamePickerView.selectedRowInComponent(0)
        let noteName = noteNames[noteNameIndex]
        let centsOffset = 0.0
        
        centsOffsetPickerView.selectRow(indexOfZeroCents, inComponent: 0, animated: true)
        
        updateForNoteName(noteName, shouldModifyNoteNamePickerView: false, centsOffSet: centsOffset, shouldMofifyCentsOffsetPickerView: false)
        
        let hz = noteNameAndCentsOffsetToHz(noteName, centsOffset: centsOffset)
        
        updateForHz(hz, shouldModifyTextField: true)
        
        let bpm = hzToBPM(hz)
        
        updateForBPM(bpm, shouldModifyTextField: true)
    }
    
    //MARK:- UITextFieldDelegate
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        if textField == hzTextField || textField == bpmTextField {
            print("range \(range) and replacementString \(string)")
            
            //sanity check http://stackoverflow.com/questions/433337/set-the-maximum-character-length-of-a-uitextfield
            if (range.length + range.location > textField.text!.characters.count) {
                return false
            }
            
            let proposedString = (textField.text! as NSString).stringByReplacingCharactersInRange(range, withString: string)
            
            let leftNumberLimit = (textField == hzTextField) ? 5 : 3
            let rightNumberLimit = 2
            
            var dotCount = 0
            var index = 0
            var numberLeftCount = 0
            var numberRightCount = 0
            
            for char in proposedString.characters {
                if char == "." {
                    if index == 0 {
                        print("don't allow dot as first char")
                        return false
                    }
                    
                    dotCount++
                    
                    if dotCount > 1 {
                        print("too many dots")
                        return false
                    }
                } else {
                    //number, not dot
                    if dotCount == 0 {
                        numberLeftCount++
                        if numberLeftCount > leftNumberLimit {
                            //limit reached for numbers left of dot
                            return false
                        }
                    } else {
                        numberRightCount++
                        if numberRightCount > rightNumberLimit {
                            //limit reached for numbers right of dot
                            return false
                        }
                    }
                }
                
                index++
            }
            
            if textField == hzTextField {
                let hz = (proposedString as NSString).doubleValue
                calculateForHz(hz)
            } else if textField == bpmTextField {
                let bpm = (proposedString as NSString).doubleValue
                calculateForBPM(bpm)
            }
        }
        
        return true
    }
    
    //MARK:- UIPickerViewDataSource
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == noteNamePickerView {
            return noteNames.count
        } else if pickerView == centsOffsetPickerView {
            return centsOffsetOptions.count
        }
        
        preconditionFailure("Unable to determine number of rows in unknown picker view: \(pickerView)")
    }
    
    //MARK:- UIPickerViewDelegate
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == noteNamePickerView {
            return noteNames[row]
        } else if pickerView == centsOffsetPickerView {
            let centsOffset = centsOffsetOptions[row]
            if centsOffset >= 0 {
                return "+" + String(centsOffsetOptions[row])
            } else {
                return String(centsOffsetOptions[row])
            }
        }
        
        preconditionFailure("Unable to determine title in unknown picker view: \(pickerView)")
    }
    
    func pickerView(pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusingView view: UIView?) -> UIView {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: pickerView.frame.width, height: 44))
        label.backgroundColor = UIColor.clearColor()
        label.textColor = UIColor.blackColor()
        label.font = UIFont.boldSystemFontOfSize(20)
        label.textAlignment = NSTextAlignment.Center
        
        if pickerView == noteNamePickerView {
            label.text = noteNames[row]
        } else if pickerView == centsOffsetPickerView {
            let centsOffset = centsOffsetOptions[row]
            var centsOffsetString = ""
            if centsOffset >= 0 {
                centsOffsetString = "+" + String(centsOffsetOptions[row])
            } else {
                centsOffsetString = String(centsOffsetOptions[row])
            }
            label.text = centsOffsetString
        }
        
        return label
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == noteNamePickerView {
            let noteName = noteNames[row]
            var centsOffset = Double(centsOffsetPickerView.selectedRowInComponent(0) - indexOfZeroCents)
            
            var shouldModifyCentsOffsetPickerView = false
            
            if centsOffsetTextField.text == "" {
                centsOffset = 0
                shouldModifyCentsOffsetPickerView = true
            }
            
            updateForNoteName(noteName, shouldModifyNoteNamePickerView: false, centsOffSet: centsOffset, shouldMofifyCentsOffsetPickerView: shouldModifyCentsOffsetPickerView)
            
            let hz = noteNameAndCentsOffsetToHz(noteName, centsOffset: centsOffset)
            
            updateForHz(hz, shouldModifyTextField: true)
            
            let bpm = hzToBPM(hz)
            
            updateForBPM(bpm, shouldModifyTextField: true)
            
        } else if pickerView == centsOffsetPickerView {
            let noteNameIndex = noteNamePickerView.selectedRowInComponent(0)
            let noteName = noteNames[noteNameIndex]
            let centsOffset = Double(row - indexOfZeroCents)
            
            updateForNoteName(noteName, shouldModifyNoteNamePickerView: false, centsOffSet: centsOffset, shouldMofifyCentsOffsetPickerView: false)
            
            let hz = noteNameAndCentsOffsetToHz(noteName, centsOffset: centsOffset)
            
            updateForHz(hz, shouldModifyTextField: true)
            
            let bpm = hzToBPM(hz)
            
            updateForBPM(bpm, shouldModifyTextField: true)
        }
    }
}