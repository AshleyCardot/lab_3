import UIKit
import CoreMotion

class ViewController: UIViewController, UITextFieldDelegate {
    
    let motionModel = MotionModel()
    
    // MARK: - UI Outlets
    @IBOutlet weak var activityLabel: UILabel!
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var stepsTodayLabel: UILabel!
    @IBOutlet weak var stepsYesterdayLabel: UILabel!
    @IBOutlet weak var currentGoalLabel: UILabel!
    @IBOutlet weak var stepGoalTextField: UITextField!
    @IBOutlet weak var playGameButton: UIButton!
    @IBOutlet weak var setStepGoalLabel: UILabel!
    @IBOutlet weak var activityStatusLabel: UILabel!
    
    // MARK: - UI Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set motion model delegate
        self.motionModel.delegate = self
        
        // Start activity and pedometer monitoring
        self.motionModel.startActivityMonitoring()
        self.motionModel.startPedometerMonitoring()
        
        // Set text field delegate
        stepGoalTextField.delegate = self
        
        // Load stored step goal
        loadStoredStepGoal()
        
        // Disable the play game button by default
        playGameButton.isEnabled = false
        
        // Fetch steps for yesterday
        fetchStepsForYesterday()
        
        styleAndCenterElements()
        
        // Dismiss keyboard on tap outside text field
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
        
    }
    
    func fetchStepsForYesterday() {
        self.motionModel.fetchStepsForYesterday {
            // Update the UI based on the fetched steps
            self.fetchAndDisplaySteps()
            
            // Check if the user met their step goal yesterday
            if self.checkStepGoalBeforePlaying() {
                // Enable the play game button
                self.playGameButton.isEnabled = true
            } else {
                // Disable the play game button
                self.playGameButton.isEnabled = false
            }
        }
    }
    
    func checkStepGoalBeforePlaying() -> Bool {
        let savedGoal = UserDefaults.standard.value(forKey: "stepGoal") as? Int ?? 5000
        if self.motionModel.stepsYesterday >= savedGoal {
            return true  // Goal met
        } else {
            return false  // Goal not met
        }
    }
    
    @IBAction func playGameButtonTapped(_ sender: UIButton) {
        if checkStepGoalBeforePlaying() {
            // Proceed to game
            let gameVC = GameViewController()
            navigationController?.pushViewController(gameVC, animated: true)
        } else {
            // Show alert to inform user they haven't met their goal
            let alert = UIAlertController(title: "Goal Not Met", message: "You need to meet your step goal from yesterday to play the game.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    // MARK: - Algin Elements
    func styleAndCenterElements() {
        // Disable autoresizing mask translation to allow programmatic constraints
        progressBar.translatesAutoresizingMaskIntoConstraints = false
        stepsTodayLabel.translatesAutoresizingMaskIntoConstraints = false
        stepsYesterdayLabel.translatesAutoresizingMaskIntoConstraints = false
        stepGoalTextField.translatesAutoresizingMaskIntoConstraints = false
        currentGoalLabel.translatesAutoresizingMaskIntoConstraints = false
        activityLabel.translatesAutoresizingMaskIntoConstraints = false
        playGameButton.translatesAutoresizingMaskIntoConstraints = false
        setStepGoalLabel.translatesAutoresizingMaskIntoConstraints = false

        // Vertical spacing between elements
        let verticalSpacing: CGFloat = 30.0
        
        // Center the progress bar horizontally and position it at the top with some padding
        NSLayoutConstraint.activate([
            progressBar.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            progressBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 80),
            progressBar.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8)
        ])

        // Center and space the stepsTodayLabel below the progress bar
        NSLayoutConstraint.activate([
            stepsTodayLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stepsTodayLabel.topAnchor.constraint(equalTo: progressBar.bottomAnchor, constant: verticalSpacing)
        ])

        // Center and space the stepsYesterdayLabel below stepsTodayLabel
        NSLayoutConstraint.activate([
            stepsYesterdayLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stepsYesterdayLabel.topAnchor.constraint(equalTo: stepsTodayLabel.bottomAnchor, constant: verticalSpacing)
        ])

        // Align "Set Step Goal" label with the stepGoalTextField horizontally
        NSLayoutConstraint.activate([
            setStepGoalLabel.trailingAnchor.constraint(equalTo: stepGoalTextField.leadingAnchor, constant: -10),
            setStepGoalLabel.centerYAnchor.constraint(equalTo: stepGoalTextField.centerYAnchor)
        ])

        // Center the stepGoalTextField below stepsYesterdayLabel
        NSLayoutConstraint.activate([
            stepGoalTextField.topAnchor.constraint(equalTo: stepsYesterdayLabel.bottomAnchor, constant: verticalSpacing),
            stepGoalTextField.leadingAnchor.constraint(equalTo: view.centerXAnchor, constant: 20), // Adjust text field position slightly
            stepGoalTextField.widthAnchor.constraint(equalToConstant: 150),
            stepGoalTextField.heightAnchor.constraint(equalToConstant: 40) // Set height for better appearance
        ])

        // Center and space the currentGoalLabel below the stepGoalTextField
        NSLayoutConstraint.activate([
            currentGoalLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            currentGoalLabel.topAnchor.constraint(equalTo: stepGoalTextField.bottomAnchor, constant: verticalSpacing)
        ])

        // Create a stack view for Current Activity
            let activityStackView = UIStackView(arrangedSubviews: [activityStatusLabel, activityLabel])
            activityStackView.axis = .horizontal
            activityStackView.alignment = .center
            activityStackView.spacing = 8.0 // Space between the label and status
            activityStackView.translatesAutoresizingMaskIntoConstraints = false
            
            // Add stack view to the main view
            view.addSubview(activityStackView)
            
            // Center and position the stack view
            NSLayoutConstraint.activate([
                activityStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                activityStackView.topAnchor.constraint(equalTo: currentGoalLabel.bottomAnchor, constant: verticalSpacing)
            ])

        // Center and space the playGameButton below the activityLabel
        NSLayoutConstraint.activate([
            playGameButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            playGameButton.topAnchor.constraint(equalTo: activityLabel.bottomAnchor, constant: verticalSpacing),
            playGameButton.widthAnchor.constraint(equalToConstant: 120),
            playGameButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }




}

extension ViewController: MotionDelegate {
    // MARK: - Motion Delegate Methods
    func activityUpdated(activity: CMMotionActivity) {
        DispatchQueue.main.async {
            if activity.walking {
                self.activityLabel.text = "Walking 🚶"
            } else if activity.running {
                self.activityLabel.text = "Running 🏃"
            } else if activity.stationary {
                self.activityLabel.text = "Stationary 🧘‍♀️"
            } else if activity.cycling {
                self.activityLabel.text = "Cycling 🚴‍♂️"
            } else if activity.automotive {
                self.activityLabel.text = "Automotive 🚗"
            } else {
                self.activityLabel.text = "Unknown 💃"
            }
        }
    }
    
    func pedometerUpdated(pedData: CMPedometerData) {
        DispatchQueue.main.async {
            let todaySteps = self.motionModel.stepsToday
            let savedGoal = UserDefaults.standard.value(forKey: "stepGoal") as? Int ?? 5000
            self.progressBar.progress = Float(todaySteps) / Float(savedGoal)
            self.stepsTodayLabel.text = "Steps Today: \(todaySteps)"
        }
    }
    
    func fetchAndDisplaySteps() {
        DispatchQueue.main.async {
            self.stepsTodayLabel.text = "Steps Today: \(self.motionModel.stepsToday)"
            self.stepsYesterdayLabel.text = "Steps Yesterday: \(self.motionModel.stepsYesterday)"
        }
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
        // Re-check step goal after updating
        if self.checkStepGoalBeforePlaying() {
            self.playGameButton.isEnabled = true
        } else {
            self.playGameButton.isEnabled = false
        }
    }
    
    // Load stored step goal when the app starts, default to 5000 if none is set
    func loadStoredStepGoal() {
        let savedGoal = UserDefaults.standard.value(forKey: "stepGoal") as? Int ?? 5000
        currentGoalLabel.text = "Current Goal: \(savedGoal) steps"
        stepGoalTextField.text = "\(savedGoal)"
    }
    
    //tap dismiss keyboard
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // return to dismiss keyboard
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
