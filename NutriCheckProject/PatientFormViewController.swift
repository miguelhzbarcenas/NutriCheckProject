//
//  PatientFormViewController.swift
//  NutriCheckProject
//
//  Created by Miguel Angel Hernandez Barcenas on 04/10/25.
//

import UIKit
import CoreData

class PatientFormViewController: UIViewController {
    
    // MARK: - Core Data Context
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    // MARK: - Properties
    var patient: Patient?
    var isEditable: Bool = true
    
    // MARK: - UI Elements
    private let scrollView = UIScrollView()
    private let stackView = UIStackView()
    
    private let firstNameField = createTextField(placeholder: "Nombre(s)")
    private let paternalNameField = createTextField(placeholder: "Apellido Paterno")
    private let maternalNameField = createTextField(placeholder: "Apellido Materno")
    private let dobPicker = UIDatePicker()
    private let genderField = createTextField(placeholder: "Sexo (ej. Masculino, Femenino)")
    private let heightField = createTextField(placeholder: "Altura (cm)", keyboardType: .decimalPad)
    private let weightField = createTextField(placeholder: "Peso (kg)", keyboardType: .decimalPad)
    private let notesView = createTextView()
    
    lazy var saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Guardar", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 10
        button.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)
        return button
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupScrollView()
        setupStackView()
        setupFormFields()
        configureView()
    }

    // MARK: - Setup
    private func setupScrollView() {
        view.backgroundColor = .systemGroupedBackground
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    private func setupStackView() {
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 15
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        scrollView.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
    }
    
    private func setupFormFields() {
        dobPicker.datePickerMode = .date
        dobPicker.preferredDatePickerStyle = .wheels
        
        stackView.addArrangedSubview(createLabel(text: "Nombre(s)"))
        stackView.addArrangedSubview(firstNameField)
        stackView.addArrangedSubview(createLabel(text: "Apellido Paterno"))
        stackView.addArrangedSubview(paternalNameField)
        stackView.addArrangedSubview(createLabel(text: "Apellido Materno"))
        stackView.addArrangedSubview(maternalNameField)
        stackView.addArrangedSubview(createLabel(text: "Fecha de Nacimiento"))
        stackView.addArrangedSubview(dobPicker)
        stackView.addArrangedSubview(createLabel(text: "Sexo"))
        stackView.addArrangedSubview(genderField)
        stackView.addArrangedSubview(createLabel(text: "Altura (cm)"))
        stackView.addArrangedSubview(heightField)
        stackView.addArrangedSubview(createLabel(text: "Peso (kg)"))
        stackView.addArrangedSubview(weightField)
        stackView.addArrangedSubview(createLabel(text: "Notas Adicionales"))
        stackView.addArrangedSubview(notesView)
        
        if isEditable {
            stackView.addArrangedSubview(UIView()) // Spacer
            stackView.addArrangedSubview(saveButton)
            NSLayoutConstraint.activate([ saveButton.heightAnchor.constraint(equalToConstant: 50) ])
        }
    }
    
    // MARK: - Configuration
    private func configureView() {
        if let patient = patient {
            // Modo Edición o Visualización
            self.title = isEditable ? "Editar Paciente" : "Detalle del Paciente"
            firstNameField.text = patient.name
            paternalNameField.text = patient.paternalLN
            maternalNameField.text = patient.maternalLN
            dobPicker.date = patient.birthday ?? Date()
            genderField.text = patient.gender
            heightField.text = String(patient.height)
            weightField.text = String(patient.weight)
            notesView.text = patient.notes
        } else {
            
            self.title = "Añadir Paciente"
        }
        
        let allFields: [UIView] = [firstNameField, paternalNameField, maternalNameField, dobPicker, genderField, heightField, weightField, notesView]
        allFields.forEach {
            if let control = $0 as? UIControl {
                control.isEnabled = isEditable
            } else if let textView = $0 as? UITextView {
                textView.isEditable = isEditable
            }
        }
    }
    
    // MARK: - Actions
    @objc private func saveTapped() {
        let patientToSave: Patient
        if let existingPatient = self.patient {
            patientToSave = existingPatient // Actualizar
        } else {
            patientToSave = Patient(context: context) // Crear
            patientToSave.id = UUID()
        }
        
        patientToSave.name = firstNameField.text
        patientToSave.paternalLN = paternalNameField.text
        patientToSave.maternalLN = maternalNameField.text
        patientToSave.birthday = dobPicker.date
        patientToSave.gender = genderField.text
        patientToSave.height = Double(heightField.text ?? "0") ?? 0
        patientToSave.weight = Double(weightField.text ?? "0") ?? 0
        patientToSave.notes = notesView.text
        
        do {
            try context.save()
            navigationController?.popViewController(animated: true)
        } catch {
            print("Error al guardar paciente: \(error)")
        }
    }
}

// MARK: - UI Helpers
fileprivate func createTextField(placeholder: String, keyboardType: UIKeyboardType = .default) -> UITextField {
    let textField = UITextField()
    textField.placeholder = placeholder
    textField.borderStyle = .roundedRect
    textField.backgroundColor = .white
    textField.heightAnchor.constraint(equalToConstant: 44).isActive = true
    textField.keyboardType = keyboardType
    return textField
}

fileprivate func createTextView() -> UITextView {
    let textView = UITextView()
    textView.font = .systemFont(ofSize: 16)
    textView.layer.cornerRadius = 8
    textView.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.5).cgColor
    textView.layer.borderWidth = 1
    textView.heightAnchor.constraint(equalToConstant: 120).isActive = true
    return textView
}

fileprivate func createLabel(text: String) -> UILabel {
    let label = UILabel()
    label.text = text
    label.font = .systemFont(ofSize: 16, weight: .medium)
    return label
}
