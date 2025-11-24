//
//  CalorieCalculatorViewController.swift
//  NutriCheckProject
//
//  Created by Miguel Angel Hernandez Barcenas on 04/10/25.
//

import UIKit
internal import CoreData

class CalorieCalculatorViewController: UIViewController {

    // MARK: - Properties
    var patient: Patient?
    private var currentTotalCalories: Double = 0.0
    
    // Contexto para guardar
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    let formulas = ["Mifflin-St Jeor", "Harris-Benedict"]
    
    let activityFactors: [(name: String, value: Double)] = [
        ("Sedentario (1.2)", 1.2),
        ("Ligero (1.375)", 1.375),
        ("Moderado (1.55)", 1.55),
        ("Activo (1.725)", 1.725),
        ("Muy Activo (1.9)", 1.9)
    ]
    
    let stressFactors: [(name: String, value: Double)] = [
        ("Ninguno (1.0)", 1.0),
        ("Cirugía Menor (1.2)", 1.2),
        ("Fractura (1.2)", 1.2),
        ("Infección Leve (1.2)", 1.2),
        ("Trauma Esquelético (1.35)", 1.35),
        ("Cirugía Mayor (1.4)", 1.4),
        ("Sepsis / Quemadura (1.5)", 1.5)
    ]
    
    var selectedFormulaIndex = 0
    var selectedActivityIndex = 0
    var selectedStressIndex = 0

    // MARK: - UI Elements
    
    private let scrollView = UIScrollView()
    private let stackView = UIStackView()
    
    private lazy var formulaTextField: UITextField = createPickerTextField(placeholder: "Selecciona Fórmula")
    private lazy var formulaPicker = UIPickerView()
    
    private lazy var activityTextField: UITextField = createPickerTextField(placeholder: "Factor de Actividad")
    private lazy var activityPicker = UIPickerView()
    
    private lazy var stressTextField: UITextField = createPickerTextField(placeholder: "Factor de Estrés")
    private lazy var stressPicker = UIPickerView()
    
    private let bmrResultLabel = createResultLabel(title: "Tasa Metabólica Basal (TMB):", value: "0 kcal")
    private let activityResultLabel = createResultLabel(title: "TMB x Actividad:", value: "0 kcal")
    private let totalResultLabel = createResultLabel(title: "Gasto Energético Total:", value: "0 kcal", isBig: true)

    // 3. Botón de Guardar
    lazy var saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Guardar Resultado en Paciente", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
        button.backgroundColor = .systemGreen
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 10
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        button.addTarget(self, action: #selector(saveResultTapped), for: .touchUpInside)
        return button
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupPickers()
        
        if let patient = patient {
            // Si el paciente ya tenía un cálculo previo guardado (opcional), podríamos cargarlo aquí
            calculateCalories()
        }
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        self.title = "Calculadora Energética"
        view.backgroundColor = .white
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 20
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
        
        addSection(title: "1. Fórmula de Cálculo", field: formulaTextField)
        stackView.addArrangedSubview(bmrResultLabel)
        addSeparator()
        
        addSection(title: "2. Factor de Actividad Física", field: activityTextField)
        stackView.addArrangedSubview(activityResultLabel)
        addSeparator()
        
        addSection(title: "3. Factor de Estrés Clínico", field: stressTextField)
        addSeparator()
        
        stackView.addArrangedSubview(totalResultLabel)
        
        // Espaciador antes del botón
        let spacer = UIView()
        spacer.heightAnchor.constraint(equalToConstant: 20).isActive = true
        stackView.addArrangedSubview(spacer)
        
        stackView.addArrangedSubview(saveButton) // Agregar botón al stack
        
        formulaTextField.text = formulas[0]
        activityTextField.text = activityFactors[0].name
        stressTextField.text = stressFactors[0].name
    }
    
    private func addSection(title: String, field: UIView) {
        let label = UILabel()
        label.text = title
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.textColor = .systemBlue
        
        stackView.addArrangedSubview(label)
        stackView.addArrangedSubview(field)
    }
    
    private func addSeparator() {
        let line = UIView()
        line.backgroundColor = .systemGray5
        line.heightAnchor.constraint(equalToConstant: 1).isActive = true
        stackView.addArrangedSubview(line)
    }
    
    private func setupPickers() {
        formulaPicker.delegate = self
        formulaPicker.dataSource = self
        formulaTextField.inputView = formulaPicker
        
        activityPicker.delegate = self
        activityPicker.dataSource = self
        activityTextField.inputView = activityPicker
        
        stressPicker.delegate = self
        stressPicker.dataSource = self
        stressTextField.inputView = stressPicker
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Listo", style: .done, target: self, action: #selector(dismissPicker))
        toolbar.setItems([UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil), doneButton], animated: false)
        
        formulaTextField.inputAccessoryView = toolbar
        activityTextField.inputAccessoryView = toolbar
        stressTextField.inputAccessoryView = toolbar
    }
    
    @objc private func dismissPicker() {
        view.endEditing(true)
    }
    
    // MARK: - Actions
    @objc private func saveResultTapped() {
        guard let patient = patient else { return }
        
        patient.setValue(currentTotalCalories, forKey: "targetCalories")
        
        do {
            try context.save()
            
            let alert = UIAlertController(title: "Guardado", message: "El cálculo de \(Int(currentTotalCalories)) kcal se ha guardado en el perfil del paciente.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                self.navigationController?.popViewController(animated: true)
            }))
            present(alert, animated: true)
            
        } catch {
            print("Error al guardar calorías: \(error)")
            let alert = UIAlertController(title: "Error", message: "No se pudo guardar el resultado.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
    }
    
    // MARK: - Calculation Logic
    private func calculateCalories() {
        guard let patient = patient else { return }
        
        let weight = patient.weight
        let height = patient.height
        let age = Double(calculateAge(birthday: patient.birthday))
        let isMale = patient.gender == "Masculino"
        
        var bmr: Double = 0.0
        
        if selectedFormulaIndex == 0 {
            // Mifflin-St Jeor
            let base = (10 * weight) + (6.25 * height) - (5 * age)
            bmr = isMale ? (base + 5) : (base - 161)
        } else {
            // Harris-Benedict
            if isMale {
                bmr = 66.5 + (13.75 * weight) + (5.003 * height) - (6.755 * age)
            } else {
                bmr = 655.1 + (9.563 * weight) + (1.850 * height) - (4.676 * age)
            }
        }
        
        let activityFactor = activityFactors[selectedActivityIndex].value
        let bmrWithActivity = bmr * activityFactor
        
        let stressFactor = stressFactors[selectedStressIndex].value
        let totalCalories = bmrWithActivity * stressFactor
        
        self.currentTotalCalories = totalCalories
        
        updateLabels(bmr: bmr, activityCalc: bmrWithActivity, total: totalCalories)
    }
    
    private func updateLabels(bmr: Double, activityCalc: Double, total: Double) {
        let fmt = NumberFormatter()
        fmt.maximumFractionDigits = 0
        
        if let bmrStr = fmt.string(from: NSNumber(value: bmr)) {
            setResultText(label: bmrResultLabel, title: "Tasa Metabólica Basal (TMB):", value: "\(bmrStr) kcal")
        }
        
        if let activityStr = fmt.string(from: NSNumber(value: activityCalc)) {
            setResultText(label: activityResultLabel, title: "TMB x Actividad (\(activityFactors[selectedActivityIndex].value)):", value: "\(activityStr) kcal")
        }
        
        if let totalStr = fmt.string(from: NSNumber(value: total)) {
            setResultText(label: totalResultLabel, title: "Gasto Energético Total:", value: "\(totalStr) kcal")
        }
    }
    
    private func calculateAge(birthday: Date?) -> Int {
        guard let birthday = birthday else { return 0 }
        let calendar = Calendar.current
        let ageComponents = calendar.dateComponents([.year], from: birthday, to: Date())
        return ageComponents.year ?? 0
    }
}

// MARK: - Picker Delegate & DataSource
extension CalorieCalculatorViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == formulaPicker { return formulas.count }
        if pickerView == activityPicker { return activityFactors.count }
        if pickerView == stressPicker { return stressFactors.count }
        return 0
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == formulaPicker { return formulas[row] }
        if pickerView == activityPicker { return activityFactors[row].name }
        if pickerView == stressPicker { return stressFactors[row].name }
        return nil
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == formulaPicker {
            selectedFormulaIndex = row
            formulaTextField.text = formulas[row]
        } else if pickerView == activityPicker {
            selectedActivityIndex = row
            activityTextField.text = activityFactors[row].name
        } else if pickerView == stressPicker {
            selectedStressIndex = row
            stressTextField.text = stressFactors[row].name
        }
        
        calculateCalories()
    }
}

// MARK: - UI Helpers
fileprivate func createPickerTextField(placeholder: String) -> UITextField {
    let tf = UITextField()
    tf.placeholder = placeholder
    tf.borderStyle = .roundedRect
    tf.textAlignment = .center
    tf.tintColor = .clear
    tf.heightAnchor.constraint(equalToConstant: 45).isActive = true
    
    let arrow = UIImageView(image: UIImage(systemName: "chevron.down"))
    arrow.tintColor = .gray
    tf.rightView = arrow
    tf.rightViewMode = .always
    return tf
}

fileprivate func createResultLabel(title: String, value: String, isBig: Bool = false) -> UILabel {
    let label = UILabel()
    label.numberOfLines = 0
    let attributedText = NSMutableAttributedString(
        string: "\(title)\n",
        attributes: [.font: UIFont.systemFont(ofSize: 14, weight: .regular), .foregroundColor: UIColor.gray]
    )
    attributedText.append(NSAttributedString(
        string: value,
        attributes: [.font: UIFont.systemFont(ofSize: isBig ? 28 : 20, weight: .bold), .foregroundColor: isBig ? UIColor.systemBlue : UIColor.black]
    ))
    label.attributedText = attributedText
    label.textAlignment = .center
    label.backgroundColor = isBig ? UIColor.systemBlue.withAlphaComponent(0.1) : .clear
    label.layer.cornerRadius = 8
    label.clipsToBounds = true
    return label
}

fileprivate func setResultText(label: UILabel, title: String, value: String) {
    let isBig = label.backgroundColor != .clear
    
    let attributedText = NSMutableAttributedString(
        string: "\(title)\n",
        attributes: [.font: UIFont.systemFont(ofSize: 14, weight: .regular), .foregroundColor: UIColor.gray]
    )
    attributedText.append(NSAttributedString(
        string: value,
        attributes: [.font: UIFont.systemFont(ofSize: isBig ? 28 : 20, weight: .bold), .foregroundColor: isBig ? UIColor.systemBlue : UIColor.black]
    ))
    label.attributedText = attributedText
}
