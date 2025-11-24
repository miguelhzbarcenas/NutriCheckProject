//
//  MacroCalculatorViewController.swift
//  NutriCheckProject
//
//  Created by Miguel Angel Hernandez Barcenas on 04/10/25.
//

import UIKit
internal import CoreData

class MacroCalculatorViewController: UIViewController {

    // MARK: - Properties
    var patient: Patient?
    var targetCalories: Double = 2000.0
    
    // Porcentajes iniciales
    var carbPct: Float = 50.0
    var protPct: Float = 20.0
    var fatPct: Float = 30.0
    
    // Constantes SMAE (Sistema Mexicano de Alimentos Equivalentes)
    let carbDivisor: Double = 15.0 // 1 Eq Carbohidrato ≈ 15g
    let protDivisor: Double = 7.0  // 1 Eq Proteína ≈ 7g
    let fatDivisor: Double = 5.0   // 1 Eq Grasa ≈ 5g
    
    // MARK: - UI Elements
    private let scrollView = UIScrollView()
    private let mainStack = UIStackView()
    
    private lazy var caloriesHeaderLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 2
        return label
    }()
    
    private let distributionBar = UIStackView()
    private let carbBarView = UIView()
    private let protBarView = UIView()
    private let fatBarView = UIView()
    
    private lazy var carbSlider = createSlider(value: carbPct, color: .systemBlue)
    private lazy var protSlider = createSlider(value: protPct, color: .systemRed)
    private lazy var fatSlider = createSlider(value: fatPct, color: .systemOrange)
    
    private lazy var carbLabel = createLabel(text: "Carbohidratos")
    private lazy var protLabel = createLabel(text: "Proteínas")
    private lazy var fatLabel = createLabel(text: "Grasas")
    
    private lazy var carbCard = createMacroCard(title: "Carbohidratos", subtitle: "4 kcal/g • /15g eq", color: .systemBlue)
    private lazy var protCard = createMacroCard(title: "Proteínas", subtitle: "4 kcal/g • /7g eq", color: .systemRed)
    private lazy var fatCard = createMacroCard(title: "Grasas", subtitle: "9 kcal/g • /5g eq", color: .systemOrange)
    
    private lazy var totalPercentageLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .bold)
        label.textAlignment = .center
        return label
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupData()
        setupUI()
        updateCalculations()
    }
    
    // MARK: - Setup
    private func setupData() {
        if let p = patient {
            if let savedCals = p.value(forKey: "targetCalories") as? Double, savedCals > 0 {
                targetCalories = savedCals
            }
        }
        
        let calString = String(format: "%.0f", targetCalories)
        let attrString = NSMutableAttributedString(string: "Calorías Meta\n", attributes: [.font: UIFont.systemFont(ofSize: 14), .foregroundColor: UIColor.gray])
        attrString.append(NSAttributedString(string: "\(calString) kcal", attributes: [.font: UIFont.systemFont(ofSize: 28, weight: .bold), .foregroundColor: UIColor.black]))
        caloriesHeaderLabel.attributedText = attrString
    }
    
    private func setupUI() {
        self.title = "Macros y Equivalentes"
        view.backgroundColor = .white
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        mainStack.axis = .vertical
        mainStack.spacing = 20
        mainStack.isLayoutMarginsRelativeArrangement = true
        mainStack.layoutMargins = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        
        view.addSubview(scrollView)
        scrollView.addSubview(mainStack)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            mainStack.topAnchor.constraint(equalTo: scrollView.topAnchor),
            mainStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            mainStack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            mainStack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            mainStack.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
        
        mainStack.addArrangedSubview(caloriesHeaderLabel)
        
        setupDistributionBar()
        mainStack.addArrangedSubview(distributionBar)
        
        mainStack.addArrangedSubview(createSectionTitle("Ajuste de Porcentajes"))
        mainStack.addArrangedSubview(createSliderRow(label: carbLabel, slider: carbSlider))
        mainStack.addArrangedSubview(createSliderRow(label: protLabel, slider: protSlider))
        mainStack.addArrangedSubview(createSliderRow(label: fatLabel, slider: fatSlider))
        mainStack.addArrangedSubview(totalPercentageLabel)
        mainStack.addArrangedSubview(createSectionTitle("Requerimiento (SMAE)"))
        
        let resultsStack = UIStackView(arrangedSubviews: [carbCard, protCard, fatCard])
        resultsStack.axis = .vertical
        resultsStack.spacing = 12
        resultsStack.distribution = .fillEqually
        mainStack.addArrangedSubview(resultsStack)
    }
    
    private func setupDistributionBar() {
        distributionBar.axis = .horizontal
        distributionBar.distribution = .fill
        distributionBar.heightAnchor.constraint(equalToConstant: 20).isActive = true
        distributionBar.layer.cornerRadius = 10
        distributionBar.clipsToBounds = true
        
        carbBarView.backgroundColor = .systemBlue
        protBarView.backgroundColor = .systemRed
        fatBarView.backgroundColor = .systemOrange
        
        distributionBar.addArrangedSubview(carbBarView)
        distributionBar.addArrangedSubview(protBarView)
        distributionBar.addArrangedSubview(fatBarView)
    }
    
    // MARK: - Logic & Updates
    @objc private func sliderChanged(_ sender: UISlider) {
        if sender == carbSlider { carbPct = sender.value }
        if sender == protSlider { protPct = sender.value }
        if sender == fatSlider { fatPct = sender.value }
        
        sender.value = round(sender.value)
        updateCalculations()
    }
    
    private func updateCalculations() {
        carbLabel.text = "Carbohidratos: \(Int(carbSlider.value))%"
        protLabel.text = "Proteínas: \(Int(protSlider.value))%"
        fatLabel.text = "Grasas: \(Int(fatSlider.value))%"
        
        let total = Int(carbSlider.value + protSlider.value + fatSlider.value)
        totalPercentageLabel.text = "Total Distribución: \(total)%"
        totalPercentageLabel.textColor = (total == 100) ? .systemGreen : .systemRed
        
        // Calcular Gramos
        let carbGrams = (targetCalories * Double(carbSlider.value) / 100.0) / 4.0
        let protGrams = (targetCalories * Double(protSlider.value) / 100.0) / 4.0
        let fatGrams = (targetCalories * Double(fatSlider.value) / 100.0) / 9.0
        
        // Calcular Equivalentes (SMAE)
        let carbEq = carbGrams / carbDivisor
        let protEq = protGrams / protDivisor
        let fatEq = fatGrams / fatDivisor
        
        updateCard(card: carbCard, grams: carbGrams, equivalents: carbEq, eqName: "Cereales/Frutas")
        updateCard(card: protCard, grams: protGrams, equivalents: protEq, eqName: "OA/Leguminosas")
        updateCard(card: fatCard, grams: fatGrams, equivalents: fatEq, eqName: "Grasas/Aceites")
        
        distributionBar.layoutIfNeeded()
        let safeTotal = total > 0 ? Double(total) : 100.0
        
        carbBarView.constraints.forEach { if $0.firstAttribute == .width { $0.isActive = false } }
        protBarView.constraints.forEach { if $0.firstAttribute == .width { $0.isActive = false } }
        
        NSLayoutConstraint.activate([
            carbBarView.widthAnchor.constraint(equalTo: distributionBar.widthAnchor, multiplier: CGFloat(Double(carbSlider.value)/safeTotal)),
            protBarView.widthAnchor.constraint(equalTo: distributionBar.widthAnchor, multiplier: CGFloat(Double(protSlider.value)/safeTotal))
        ])
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    private func updateCard(card: UIView, grams: Double, equivalents: Double, eqName: String) {
        // Tag 100: Gramos (Grande)
        if let gramsLabel = card.viewWithTag(100) as? UILabel {
            gramsLabel.text = String(format: "%.0f g", grams)
        }
        
        // Tag 101: Equivalentes (Nuevo)
        if let eqLabel = card.viewWithTag(101) as? UILabel {
            eqLabel.text = String(format: "%.1f Equivalentes", equivalents)
        }
    }
    
    // MARK: - UI Factories
    private func createSlider(value: Float, color: UIColor) -> UISlider {
        let slider = UISlider()
        slider.minimumValue = 0
        slider.maximumValue = 100
        slider.value = value
        slider.minimumTrackTintColor = color
        slider.addTarget(self, action: #selector(sliderChanged), for: .valueChanged)
        return slider
    }
    
    private func createLabel(text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 14, weight: .medium)
        return label
    }
    
    private func createSliderRow(label: UILabel, slider: UISlider) -> UIStackView {
        let stack = UIStackView(arrangedSubviews: [label, slider])
        stack.axis = .vertical
        stack.spacing = 5
        return stack
    }
    
    private func createSectionTitle(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textColor = .black
        return label
    }
    
    private func createMacroCard(title: String, subtitle: String, color: UIColor) -> UIView {
        let container = UIView()
        container.backgroundColor = color.withAlphaComponent(0.1)
        container.layer.cornerRadius = 10
        container.layer.borderWidth = 1
        container.layer.borderColor = color.withAlphaComponent(0.3).cgColor
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 16, weight: .medium)
        titleLabel.textColor = .black
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let subLabel = UILabel()
        subLabel.text = subtitle
        subLabel.font = .systemFont(ofSize: 12)
        subLabel.textColor = .gray
        subLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let gramsLabel = UILabel()
        gramsLabel.tag = 100
        gramsLabel.text = "0 g"
        gramsLabel.font = .systemFont(ofSize: 24, weight: .bold)
        gramsLabel.textColor = color
        gramsLabel.textAlignment = .right
        gramsLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let eqLabel = UILabel()
        eqLabel.tag = 101
        eqLabel.text = "0 eq"
        eqLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        eqLabel.textColor = .darkGray
        eqLabel.textAlignment = .right
        eqLabel.translatesAutoresizingMaskIntoConstraints = false
        
        container.addSubview(titleLabel)
        container.addSubview(subLabel)
        container.addSubview(gramsLabel)
        container.addSubview(eqLabel)
        
        NSLayoutConstraint.activate([
            container.heightAnchor.constraint(equalToConstant: 85),
            
            titleLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 15),
            
            subLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2),
            subLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 15),
            
            gramsLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 12),
            gramsLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -15),
            
            eqLabel.topAnchor.constraint(equalTo: gramsLabel.bottomAnchor, constant: 2),
            eqLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -15)
        ])
        
        return container
    }
}
