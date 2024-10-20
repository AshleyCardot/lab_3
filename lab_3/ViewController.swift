import UIKit
import CoreMotion

class ViewController: UIViewController, UITextFieldDelegate  {
    
    let motionModel = MotionModel()

    // MARK: =====UI Outlets=====
    @IBOutlet weak var activityLabel: UILabel!
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var stepsTodayLabel: UILabel!
    @IBOutlet weak var stepsYesterdayLabel: UILabel!
    @IBOutlet weak var currentGoalLabel: UILabel!
    @IBOutlet weak var stepGoalTextField: UITextField!
    
    
    // MARK: =====UI Lifecycle=====
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.motionModel.delegate = self
        
        self.motionModel.startActivityMonitoring()
        self.motionModel.startPedometerMonitoring()
        
        view.addSubview(stepsTodayLabel)
        view.addSubview(stepsYesterdayLabel)
        
        
        stepGoalTextField.delegate = self
                
        setupLayout()
        fetchAndDisplaySteps()
        loadStoredStepGoal()
        
        
        // tap outside text box to have it disappear
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }


    


}

extension ViewController: MotionDelegate{
    // MARK: =====Motion Delegate Methods=====
    func activityUpdated(activity:CMMotionActivity){
        
        //self.activityLabel.text = "🚶: \(activity.walking), 🏃: \(activity.running), 🧘‍♀️: \(activity.stationary), 💃: \(activity.unknown), 🚴‍♂️: \(activity.cycling),  🚗: \(activity.automotive)"
        
        // if statement to print current activity
        if activity.walking {
            self.activityLabel.text = "Walking🚶"
        }else if activity.running {
            self.activityLabel.text = "Running 🏃"
        }else if activity.stationary {
            self.activityLabel.text = "Stationary 🧘‍♀️"
        }else if activity.unknown {
            self.activityLabel.text = "Unknown 💃"
        }else if activity.cycling {
            self.activityLabel.text = "Cycling 🚴‍♂️"
        }else if activity.automotive {
            self.activityLabel.text = "Automotive 🚗"
        }
    }
    
    func setupLayout() {
        // Add constraints for labels
        stepsTodayLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        stepsTodayLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -50).isActive = true
            
        stepsYesterdayLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        stepsYesterdayLabel.topAnchor.constraint(equalTo: stepsTodayLabel.bottomAnchor, constant: 20).isActive = true
    }
    
    func pedometerUpdated(pedData:CMPedometerData){
        
        let todaySteps = self.motionModel.stepsToday
        let savedGoal = UserDefaults.standard.value(forKey: "stepGoal") as? Int ?? 5000

        // display the output directly on the phone
        DispatchQueue.main.async {
            
            self.progressBar.progress = Float(todaySteps) / Float(savedGoal)
        }
    }
    
    func updatePedomter(){
        
        let todaySteps = self.motionModel.stepsToday
        let savedGoal = UserDefaults.standard.value(forKey: "stepGoal") as? Int ?? 5000
        
    

        // display the output directly on the phone
        DispatchQueue.main.async {
            self.progressBar.progress = Float(todaySteps) / Float(savedGoal)
            print("Progress: \(self.progressBar.progress)")
        }
    }
    
    func fetchAndDisplaySteps() {
            
        // Delay to allow time for steps to be fetched
        DispatchQueue.main.async {
            self.stepsTodayLabel.text = "Steps Today: \(self.motionModel.stepsToday)"
            self.stepsYesterdayLabel.text = "Steps Yesterday: \(self.motionModel.stepsYesterday)"
            
            // Print to console
            //print("Steps Today: \(self.motionModel.stepsToday)")
            //print("Steps Yesterday: \(self.motionModel.stepsYesterday)")
            
        }
        
        updatePedomter()
        


    }
    
    // Save step goal when text field editing is done
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let goalText = textField.text, let stepGoal = Int(goalText), stepGoal > 0 {
            saveStepGoal(stepGoal)
        } else {
            // If no valid input is given, set the default goal to 5000
            saveStepGoal(5000)
        }
    }
        
    // Save step goal to UserDefaults
    func saveStepGoal(_ goal: Int) {
        UserDefaults.standard.set(goal, forKey: "stepGoal")
        currentGoalLabel.text = "Current Goal: \(goal) steps"
    }
        
    // Load stored step goal when the app starts, default to 5000 if none is set
    func loadStoredStepGoal() {
        let savedGoal = UserDefaults.standard.value(forKey: "stepGoal") as? Int ?? 5000
        currentGoalLabel.text = "Current Goal: \(savedGoal) steps"
        stepGoalTextField.text = "\(savedGoal)"
    }
    
    // return to dismiss keyboard
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()  // Dismisses the keyboard
        return true
    }
    
    //tap dismiss keyboard
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    
}

