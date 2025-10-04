//
//  PatientListViewController.swift
//  NutriCheckProject
//
//  Created by Miguel Angel Hernandez Barcenas on 04/10/25.
//

import UIKit
import CoreData

class PatientListViewController: UIViewController {

    // MARK: - Core Data Context
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    // MARK: - Properties
    private var patients = [Patient]()
    
    // MARK: - UI Elements
    lazy var tableView: UITableView = {
        let table = UITableView()
        table.translatesAutoresizingMaskIntoConstraints = false
        table.delegate = self
        table.dataSource = self
        table.register(UITableViewCell.self, forCellReuseIdentifier: "patientCell")
        return table
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchPatients()
    }

    // MARK: - Setup
    private func setupUI() {
        self.title = "Pacientes"
        view.backgroundColor = .white
        
        navigationItem.rightBarButtonItem?.target = self
        navigationItem.rightBarButtonItem?.action = #selector(addPatientTapped)

        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    // MARK: - Core Data Functions
    private func fetchPatients() {
        do {
            self.patients = try context.fetch(Patient.fetchRequest())
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        } catch {
            print("Error fetching patients: \(error)")
        }
    }
    
    // MARK: - Actions
    @objc func addPatientTapped() {
        performSegue(withIdentifier: "addPatientSegue", sender: self)
    }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetailSegue" {
            if let destinationVC = segue.destination as? PatientDetailViewController,
               let selectedPatient = sender as? Patient {
                destinationVC.patient = selectedPatient
            }
        } else if segue.identifier == "addPatientSegue" {
             if let destinationVC = segue.destination as? PatientFormViewController {
                destinationVC.isEditable = true
                destinationVC.patient = nil
            }
        }
    }
}

// MARK: - UITableView Delegate & DataSource
extension PatientListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return patients.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "patientCell", for: indexPath)
        let patient = patients[indexPath.row]
        
        let fullName = [patient.name, patient.paternalLN, patient.maternalLN].compactMap { $0 }.joined(separator: " ")
        cell.textLabel?.text = fullName
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedPatient = patients[indexPath.row]
        performSegue(withIdentifier: "showDetailSegue", sender: selectedPatient)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
