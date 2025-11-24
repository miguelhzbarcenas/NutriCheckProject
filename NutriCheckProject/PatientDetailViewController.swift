//
//  PatientDetailViewController.swift
//  NutriCheckProject
//
//  Created by Miguel Angel Hernandez Barcenas on 04/10/25.
//

import UIKit
internal import CoreData

class PatientDetailViewController: UIViewController {

    // MARK: - Core Data Context
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    // MARK: - Properties
    var patient: Patient?
    
    // MARK: - UI Elements
    private let editButton = createMenuButton(title: "Editar Datos")
    private let viewButton = createMenuButton(title: "Visualizar Datos")
    private let deleteButton = createMenuButton(title: "Eliminar Paciente", color: .systemRed)
    private let calculateButton = createMenuButton(title: "Calculadora Básica")
    private let waterButton = createMenuButton(title: "Requerimiento Hídrico", color: .systemCyan)
    private let macroButton = createMenuButton(title: "Distribución de Macros", color: .systemOrange)
    private let espenButton = createMenuButton(title: "Cálculo ESPEN (UCI)", color: .systemPurple)

    lazy var stackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [editButton, viewButton, calculateButton, macroButton, waterButton, espenButton, deleteButton])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 20
        return stack
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        addTargets()
    }

    // MARK: - Setup
    private func setupUI() {
        let fullName = [patient?.name, patient?.paternalLN, patient?.maternalLN].compactMap { $0 }.joined(separator: " ")
        self.title = fullName
        view.backgroundColor = .systemGroupedBackground
        
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30)
        ])
    }
    
    private func addTargets() {
        editButton.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        viewButton.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        deleteButton.addTarget(self, action: #selector(deleteTapped), for: .touchUpInside)
        calculateButton.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        waterButton.addTarget(self, action: #selector(waterTapped), for: .touchUpInside)
        espenButton.addTarget(self, action: #selector(espenTapped), for: .touchUpInside)
        macroButton.addTarget(self, action: #selector(macroTapped), for: .touchUpInside)
    }
    
    // MARK: - Actions
    @objc func buttonTapped(_ sender: UIButton) {
        if sender == editButton || sender == viewButton {
             performSegue(withIdentifier: "goToFormSegue", sender: sender)
        } else if sender == calculateButton {
             performSegue(withIdentifier: "showCalculatorSegue", sender: self)
        }
    }
    
    @objc func espenTapped() {
        let espenVC = EspenCalculatorViewController()
        espenVC.patient = self.patient
        navigationController?.pushViewController(espenVC, animated: true)
    }
    
    @objc func macroTapped() {
        let macroVC = MacroCalculatorViewController()
        macroVC.patient = self.patient
        navigationController?.pushViewController(macroVC, animated: true)
    }
    
    @objc func waterTapped() {
            let waterVC = WaterCalculatorViewController()
            waterVC.patient = self.patient
            navigationController?.pushViewController(waterVC, animated: true)
        }
    
    @objc func deleteTapped() {
        let alert = UIAlertController(title: "Confirmar Eliminación", message: "Este paciente será eliminado permanentemente. ¿Deseas continuar?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Eliminar", style: .destructive, handler: { [weak self] _ in
            self?.deletePatient()
        }))
        present(alert, animated: true)
    }
    
    private func deletePatient() {
        guard let patientToDelete = self.patient else { return }
        
        context.delete(patientToDelete)
        
        do {
            try context.save()
            navigationController?.popViewController(animated: true)
        } catch {
            print("Error eliminando paciente: \(error)")
        }
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToFormSegue" {
            guard let destinationVC = segue.destination as? PatientFormViewController,
                  let buttonSender = sender as? UIButton else { return }
            
            destinationVC.patient = self.patient
            destinationVC.isEditable = (buttonSender == editButton)
            
        } else if segue.identifier == "showCalculatorSegue" {
            guard let destinationVC = segue.destination as? CalorieCalculatorViewController else { return }
            destinationVC.patient = self.patient
        }
    }
}

fileprivate func createMenuButton(title: String, color: UIColor = .systemBlue) -> UIButton {
    let button = UIButton(type: .system)
    button.setTitle(title, for: .normal)
    button.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
    button.backgroundColor = .white
    button.setTitleColor(color, for: .normal)
    button.layer.cornerRadius = 10
    button.heightAnchor.constraint(equalToConstant: 50).isActive = true
    return button
}
