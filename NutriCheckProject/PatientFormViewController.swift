//
//  PatientFormViewController.swift
//  NutriCheckProject
//
//  Created by Miguel Angel Hernandez Barcenas on 04/10/25.
//

import UIKit
internal import CoreData

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
    private let genderSegmentedControl: UISegmentedControl = {
        let control = UISegmentedControl(items: ["Masculino", "Femenino"])
        control.selectedSegmentIndex = 0
        control.heightAnchor.constraint(equalToConstant: 44).isActive = true
        return control
    }()

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
        setupKeyboardToolbar()
        configureView()
        setupKeyboardObservers() // NUEVO: Iniciar escucha del teclado
    }
    
    deinit {
        // Buena práctica: Dejar de escuchar notificaciones al destruir la vista
        NotificationCenter.default.removeObserver(self)
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
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
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
        dobPicker.maximumDate = Date()
        
        stackView.addArrangedSubview(createLabel(text: "Nombre(s) *"))
        stackView.addArrangedSubview(firstNameField)
        
        stackView.addArrangedSubview(createLabel(text: "Apellido Paterno *"))
        stackView.addArrangedSubview(paternalNameField)
        
        stackView.addArrangedSubview(createLabel(text: "Apellido Materno"))
        stackView.addArrangedSubview(maternalNameField)
        
        stackView.addArrangedSubview(createLabel(text: "Fecha de Nacimiento"))
        stackView.addArrangedSubview(dobPicker)
        
        stackView.addArrangedSubview(createLabel(text: "Sexo"))
        stackView.addArrangedSubview(genderSegmentedControl)
        
        stackView.addArrangedSubview(createLabel(text: "Altura (cm) *"))
        stackView.addArrangedSubview(heightField)
        
        stackView.addArrangedSubview(createLabel(text: "Peso (kg) *"))
        stackView.addArrangedSubview(weightField)
        
        stackView.addArrangedSubview(createLabel(text: "Notas Adicionales"))
        stackView.addArrangedSubview(notesView)
        
        if isEditable {
            stackView.addArrangedSubview(UIView())
            stackView.addArrangedSubview(saveButton)
            NSLayoutConstraint.activate([ saveButton.heightAnchor.constraint(equalToConstant: 50) ])
        }
    }
    
    private func setupKeyboardToolbar() {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "Listo", style: .done, target: self, action: #selector(dismissKeyboard))
        toolbar.setItems([flexSpace, doneButton], animated: false)
        
        heightField.inputAccessoryView = toolbar
        weightField.inputAccessoryView = toolbar
    }
    
    // MARK: - Keyboard Handling Logic (NUEVO)
    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc private func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            // Ajustamos el "padding" inferior del scroll view
            let contentInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: keyboardSize.height, right: 0.0)
            scrollView.contentInset = contentInsets
            scrollView.scrollIndicatorInsets = contentInsets
        }
    }

    @objc private func keyboardWillHide(notification: NSNotification) {
        // Restauramos el scroll view a la normalidad
        let contentInsets = UIEdgeInsets.zero
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
    }

    // MARK: - Configuration
    private func configureView() {
        if let patient = patient {
            self.title = isEditable ? "Editar Paciente" : "Detalle del Paciente"
            firstNameField.text = patient.name
            paternalNameField.text = patient.paternalLN
            maternalNameField.text = patient.maternalLN
            dobPicker.date = patient.birthday ?? Date()
            
            if let gender = patient.gender {
                if gender == "Masculino" {
                    genderSegmentedControl.selectedSegmentIndex = 0
                } else if gender == "Femenino" {
                    genderSegmentedControl.selectedSegmentIndex = 1
                }
            }
            
            heightField.text = patient.height > 0 ? String(format: "%.0f", patient.height) : ""
            weightField.text = patient.weight > 0 ? String(patient.weight) : ""
            notesView.text = patient.notes
        } else {
            self.title = "Añadir Paciente"
        }
        
        let allFields: [UIView] = [firstNameField, paternalNameField, maternalNameField, dobPicker, genderSegmentedControl, heightField, weightField, notesView]
        allFields.forEach {
            if let control = $0 as? UIControl {
                control.isEnabled = isEditable
            } else if let textView = $0 as? UITextView {
                textView.isEditable = isEditable
            }
        }
        dobPicker.isUserInteractionEnabled = isEditable
    }

    // MARK: - Validation Logic
    private func validateData() -> String? {
        guard let name = firstNameField.text, !name.trimmingCharacters(in: .whitespaces).isEmpty else {
            return "Por favor ingresa el nombre del paciente."
        }
        
        guard let paternal = paternalNameField.text, !paternal.trimmingCharacters(in: .whitespaces).isEmpty else {
            return "El apellido paterno es obligatorio."
        }
        
        guard let heightText = heightField.text, let heightVal = Double(heightText), heightVal > 0 && heightVal < 300 else {
            return "Ingresa una altura válida en cm (ej. 170)."
        }
        
        guard let weightText = weightField.text, let weightVal = Double(weightText), weightVal > 0 && weightVal < 500 else {
            return "Ingresa un peso válido en kg."
        }
        
        return nil
    }

    // MARK: - Actions
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    @objc private func saveTapped() {
        if let errorMessage = validateData() {
            showErrorAlert(message: errorMessage)
            return
        }
        
        let patientToSave: Patient
        if let existingPatient = self.patient {
            patientToSave = existingPatient
        } else {
            patientToSave = Patient(context: context)
            patientToSave.id = UUID()
            patientToSave.creation = Date()
        }
        
        let selectedGender = genderSegmentedControl.titleForSegment(at: genderSegmentedControl.selectedSegmentIndex)
        
        patientToSave.name = firstNameField.text?.trimmingCharacters(in: .whitespaces)
        patientToSave.paternalLN = paternalNameField.text?.trimmingCharacters(in: .whitespaces)
        patientToSave.maternalLN = maternalNameField.text?.trimmingCharacters(in: .whitespaces)
        patientToSave.birthday = dobPicker.date
        patientToSave.gender = selectedGender
        
        patientToSave.height = Double(heightField.text!) ?? 0
        patientToSave.weight = Double(weightField.text!) ?? 0
        patientToSave.notes = notesView.text
        
        do {
            try context.save()
            navigationController?.popViewController(animated: true)
        } catch {
            print("Error al guardar paciente: \(error)")
            showErrorAlert(message: "Error interno al guardar en base de datos.")
        }
    }
    
    private func showErrorAlert(message: String) {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
        
        let alert = UIAlertController(title: "Datos Incompletos", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Entendido", style: .default, handler: nil))
        present(alert, animated: true)
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
    textField.autocapitalizationType = (keyboardType == .default) ? .words : .none
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
    label.textColor = .darkGray
    return label
}
