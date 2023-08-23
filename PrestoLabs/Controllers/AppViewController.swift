//
//  AppViewController.swift
//  PrestoLabs
//
//  Created by tzh.
//

import UIKit
import ProgressHUD

/**
 The main view controller for the app.
 
 This view controller manages the main interface and user interactions.
 */
class AppViewController: UIViewController {
    /// A segmented control used to switch between Order Book and Recent Trades views.
    lazy var segmentControl: UISegmentedControl = {
        let segmentControl = UISegmentedControl(items: ["Order Book", "Recent Trades"])
        segmentControl.selectedSegmentIndex = 0 // Set the initial selected segment
        return segmentControl
        
    }()
    
    /**
     Called after the view controller's view is loaded into memory.
     
     Use this method to perform any additional setup for the view controller.
     */
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    
}
// MARK: - Error Presentation and UI Setup

extension AppViewController {
    
    /**
     Presents an error message to the user.
     
     - Parameter error: The error to display.
     - Parameter customAction: An optional custom action to include in the alert.
     - Parameter handler: An optional handler for the default action.
     
     This method displays an alert with the error message to the user.
     */
    func present(error: Error, customAction: UIAlertAction? = nil, handler: ((UIAlertAction) -> Void)? = nil) {
        DispatchQueue.main.async {
            self.present(title: "Oops", message: error.localizedDescription)
        }
    }
    
    /**
     Presents an alert with a title and message to the user.
     
     - Parameter title: The title of the alert.
     - Parameter message: The message to display in the alert.
     - Parameter customAction: An optional custom action to include in the alert.
     - Parameter handler: An optional handler for the default action.
     
     This method displays an alert with the specified title and message to the user.
     */
    func present(title: String, message: String, customAction: UIAlertAction? = nil, handler: ((UIAlertAction) -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: handler))
        if let customAction = customAction {
            alert.addAction(customAction)
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        
        present(alert, animated: true)
    }
    func setUpHeaderForOrder() {
    }
    
    /**
     Sets up header labels with custom text for display.
     
     - Parameter t1Str: Text for the first label.
     - Parameter t2Str: Text for the second label.
     - Parameter t3Str: Text for the third label.
     
     This method creates and positions labels for displaying custom header information.
     */
    func setUpHeader(t1Str: String , t2Str: String, t3Str: String) {
        let headerView = UIView()
        let lblPrice = UILabel()
        lblPrice.text = t1Str// "Price(USD)"
        lblPrice.font = UIFont.systemFont(ofSize: 16)
        headerView.addSubview(lblPrice)
        lblPrice.translatesAutoresizingMaskIntoConstraints = false
        let lblQty = UILabel()
        lblQty.text = t2Str //"Qty"
        lblQty.font = UIFont.systemFont(ofSize: 16)
        headerView.addSubview(lblQty)
        lblQty.translatesAutoresizingMaskIntoConstraints = false
        let lblTime = UILabel()
        lblTime.text = t3Str // "Time"
        lblTime.font = UIFont.systemFont(ofSize: 16)
        lblTime.textAlignment = .right
        headerView.addSubview(lblTime)
        lblTime.translatesAutoresizingMaskIntoConstraints = false
        
        let lineView2 = UIView()
        lineView2.backgroundColor = .lightGray
        view.addSubview(headerView)
        view.addSubview(lineView2)
        lineView2.translatesAutoresizingMaskIntoConstraints = false
        headerView.translatesAutoresizingMaskIntoConstraints = false
        let guide = self.view.safeAreaLayoutGuide
        
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: guide.topAnchor, constant: 30),
            headerView.leadingAnchor.constraint(equalTo: guide.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: guide.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 30)
        ])
        NSLayoutConstraint.activate([
            lineView2.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 0),
            lineView2.leadingAnchor.constraint(equalTo: guide.leadingAnchor),
            lineView2.trailingAnchor.constraint(equalTo: guide.trailingAnchor),
            lineView2.heightAnchor.constraint(equalToConstant: 1)
        ])
        NSLayoutConstraint.activate([
            lblQty.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 0),
            lblQty.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            lblQty.heightAnchor.constraint(equalTo: headerView.heightAnchor)
        ])
        NSLayoutConstraint.activate([
            lblPrice.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 0),
            lblPrice.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: 10),
            lblPrice.heightAnchor.constraint(equalTo: headerView.heightAnchor)
        ])
        NSLayoutConstraint.activate([
            lblTime.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 0),
            lblTime.leadingAnchor.constraint(equalTo: lblQty.trailingAnchor, constant: 0),
            lblTime.trailingAnchor.constraint(equalTo: headerView.trailingAnchor,constant: -10),
            lblTime.heightAnchor.constraint(equalTo: headerView.heightAnchor)
        ])
        
    }
    
}
// MARK: - Loading Indicator

extension AppViewController {
    /**
     Displays a loading indicator and disables user interaction.
     
     This method shows a loading indicator and prevents user interaction.
     */
    func startLoading() {
        ProgressHUD.show()
        self.view.isUserInteractionEnabled = false
    }
    /**
     Stops the loading indicator and restores user interaction.
     
     This method hides the loading indicator and allows user interaction.
     */
    
    func stopLoading() {
        self.view.isUserInteractionEnabled = true
        ProgressHUD.dismiss()
    }
}
