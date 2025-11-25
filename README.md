# NutriCheck 🍃✔️
### *Herramienta móvil para cálculo nutricional clínico*

NutriCheck es una aplicación diseñada para profesionales de la salud y nutrición. Simplifica la valoración clínica al automatizar cálculos complejos como gasto energético, distribución de macronutrientes y requerimientos hídricos.

---

## 📱 Características Principales

### 🔸 Gestión de Pacientes
- Registro y almacenamiento de datos antropométricos.
- Persistencia local mediante **CoreData**.

### 🔸 Cálculos Nutricionales Automatizados
- **Gasto Energético Total (GET):**  
  Fórmulas: *Mifflin-St Jeor* y *Harris-Benedict*, con factores de:
  - Actividad
  - Estrés clínico

- **Distribución de Macronutrientes:**  
  En **gramos** y **equivalentes SMAE** según objetivo calórico.

- **Nutrición Clínica (UCI):**  
  Guías **ESPEN** para pacientes críticos, considerando IMC y obesidad.

- **Requerimiento Hídrico:**  
  Estimación basada en peso y estilo de vida.

---

## 🎨 Identidad Gráfica

[NutriCheckIcon jpeg 04-05-10-363](https://github.com/user-attachments/assets/db221113-ac6a-428c-9b88-c3c97331b543)


**Significado del logo:**

- 🌿 **Hoja:** nutrición, bienestar, salud natural  
- ✔️ **Check:** precisión, validación clínica  
- 🔗 **Conjunto:** balance entre ciencia y nutrición

---

## 🧩 Arquitectura y Dependencias

Proyecto 100% **nativo**, sin CocoaPods ni Swift Package Manager.

### Frameworks utilizados

| Framework     | Uso |
|---------------|------|
| **UIKit**     | UI programática (ViewCode), navegación |
| **CoreData**  | Persistencia (CRUD de pacientes) |
| **Foundation**| Lógica, fechas, formato numérico |

---

## ⚙️ Especificaciones Técnicas

| Característica | Valor | Justificación |
|----------------|--------|---------------|
| **Plataforma** | iPhone | Uso clínico rápido a pie de cama |
| **iOS mínimo** | **15.6+** | Uso de APIs modernas y compatibilidad |
| **Orientación** | Vertical | Formularios más estables y legibles |

---
