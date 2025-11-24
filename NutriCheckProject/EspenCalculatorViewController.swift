//
//  EspenCalculatorViewController.swift
//  NutriCheckProject
//
//  Created by Miguel Angel Hernandez Barcenas on 04/10/25.
//

import UIKit

class EspenCalculatorViewController: UIViewController {

    // MARK: - Properties
    var patient: Patient?
    
    // MARK: - UI Elements
    private let scrollView = UIScrollView()
    private let stackView = UIStackView()
    private lazy var bmiCard = createInfoCard(title: "IMC (BMI)", value: "--")
    private lazy var categoryCard = createInfoCard(title: "Categoría", value: "--", valueColor: .systemOrange)
    private lazy var formulaCard = createInfoCard(title: "Guía ESPEN Aplicada", value: "Analizando...", isMultiLine: true)
    
    private let resultContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .systemPurple
        view.layer.cornerRadius = 15
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let resultTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Objetivo Calórico (UCI)"
        label.textColor = .white.withAlphaComponent(0.9)
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let resultValueLabel: UILabel = {
        let label = UILabel()
        label.text = "0 - 0 kcal/día"
        label.textColor = .white
        label.font = .systemFont(ofSize: 32, weight: .bold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        calculateEspen()
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        self.title = "Protocolo ESPEN"
        view.backgroundColor = .systemGroupedBackground
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
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
        
        setupResultContainer()
        stackView.addArrangedSubview(resultContainer)
        
        stackView.addArrangedSubview(createSectionHeader(text: "Diagnóstico Nutricional"))
        stackView.addArrangedSubview(bmiCard)
        stackView.addArrangedSubview(categoryCard)
        
        stackView.addArrangedSubview(createSectionHeader(text: "Lógica Clínica"))
        stackView.addArrangedSubview(formulaCard)
        
        // Nota explicativa
        let noteLabel = UILabel()
        noteLabel.text = "Nota: Cálculos basados en Guías ESPEN sobre nutrición clínica en la unidad de cuidados intensivos (UCI). En obesidad mórbida se utiliza Peso Ideal."
        noteLabel.numberOfLines = 0
        noteLabel.font = .systemFont(ofSize: 12)
        noteLabel.textColor = .gray
        noteLabel.textAlignment = .justified
        
        stackView.addArrangedSubview(noteLabel)
    }
    
    private func setupResultContainer() {
        resultContainer.addSubview(resultTitleLabel)
        resultContainer.addSubview(resultValueLabel)
        
        NSLayoutConstraint.activate([
            resultContainer.heightAnchor.constraint(equalToConstant: 120),
            
            resultTitleLabel.topAnchor.constraint(equalTo: resultContainer.topAnchor, constant: 20),
            resultTitleLabel.centerXAnchor.constraint(equalTo: resultContainer.centerXAnchor),
            
            resultValueLabel.topAnchor.constraint(equalTo: resultTitleLabel.bottomAnchor, constant: 10),
            resultValueLabel.centerXAnchor.constraint(equalTo: resultContainer.centerXAnchor),
            resultValueLabel.leadingAnchor.constraint(equalTo: resultContainer.leadingAnchor, constant: 10),
            resultValueLabel.trailingAnchor.constraint(equalTo: resultContainer.trailingAnchor, constant: -10)
        ])
    }
    
    // MARK: - Logic (ESPEN Guidelines)
    private func calculateEspen() {
        guard let patient = patient, patient.height > 0, patient.weight > 0 else {
            resultValueLabel.text = "Datos Insuficientes"
            return
        }
        
        let heightM = patient.height / 100.0
        let weightKg = patient.weight
        
       //Calcular IMC
        let bmi = weightKg / (heightM * heightM)
        updateCard(card: bmiCard, value: String(format: "%.1f kg/m²", bmi))
        
        // Determinar Categoría y Rango
        var minKcal: Double = 0
        var maxKcal: Double = 0
        var categoryText = ""
        var formulaText = ""
        
        if bmi < 30 {
            // Paciente No Obeso (Crítico estándar)
            // ESPEN: 25-30 kcal/kg/día
            categoryText = "Peso Normal / Sobrepeso"
            formulaText = "Paciente Normopeso: Se utiliza el rango estándar UCI de 25-30 kcal/kg de peso real."
            minKcal = 25 * weightKg
            maxKcal = 30 * weightKg
            
        } else if bmi >= 30 && bmi <= 50 {
            // Obesidad Grado I y II
            // ESPEN: 11-14 kcal/kg de PESO ACTUAL
            categoryText = "Obesidad (Grado I-II)"
            formulaText = "Obesidad (IMC 30-50): Guía ESPEN recomienda restricción calórica de 11-14 kcal/kg usando el PESO ACTUAL."
            minKcal = 11 * weightKg
            maxKcal = 14 * weightKg
            
        } else {
            // Obesidad Mórbida (Grado III, BMI > 50)
            // ESPEN: 22-25 kcal/kg de PESO IDEAL
            categoryText = "Obesidad Mórbida (Grado III)"
            
            // CPeso Ideal (Fórmula rápida: BMI 22.5 * Altura^2)
            // Nota: ESPEN no define una fórmula única de IBW, usamos BMI 22.5 como estándar medio
            let idealWeight = 22.5 * (heightM * heightM)
            
            formulaText = "Obesidad Severa (IMC > 50): Se utiliza el PESO IDEAL (\(Int(idealWeight)) kg) con un rango de 22-25 kcal/kg."
            
            minKcal = 22 * idealWeight
            maxKcal = 25 * idealWeight
        }
        
        updateCard(card: categoryCard, value: categoryText)
        updateCard(card: formulaCard, value: formulaText)
        
        resultValueLabel.text = "\(Int(minKcal)) - \(Int(maxKcal)) kcal"
    }
    
    // MARK: - UI Helpers
    private func updateCard(card: UIView, value: String) {
        if let label = card.viewWithTag(100) as? UILabel {
            label.text = value
        }
    }
    
    private func createSectionHeader(text: String) -> UILabel {
        let label = UILabel()
        label.text = text.uppercased()
        label.font = .systemFont(ofSize: 13, weight: .bold)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    
    private func createInfoCard(title: String, value: String, valueColor: UIColor = .label, isMultiLine: Bool = false) -> UIView {
        let container = UIView()
        container.backgroundColor = .white
        container.layer.cornerRadius = 10
        // Sombra suave
        container.layer.shadowColor = UIColor.black.cgColor
        container.layer.shadowOpacity = 0.05
        container.layer.shadowOffset = CGSize(width: 0, height: 2)
        container.layer.shadowRadius = 4
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 14, weight: .regular)
        titleLabel.textColor = .secondaryLabel
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let valueLabel = UILabel()
        valueLabel.tag = 100
        valueLabel.text = value
        valueLabel.textColor = valueColor
        valueLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        
        if isMultiLine {
            valueLabel.numberOfLines = 0
            valueLabel.font = .systemFont(ofSize: 16, weight: .medium)
        }
        
        container.addSubview(titleLabel)
        container.addSubview(valueLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 15),
            titleLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -15),
            
            valueLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 5),
            valueLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 15),
            valueLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -15),
            valueLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -15)
        ])
        
        return container
    }
}
