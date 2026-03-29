# 🏏 IPL First Innings Score Predictor

A machine learning project that predicts the final first innings score of an IPL match based on the current match situation — using ball-by-ball data from IPL seasons 2008 to 2019.

---

## 📌 Overview

Given live match inputs like current overs, runs, wickets, and recent scoring rate, this model predicts the expected final score range for the batting team.

The model is trained on IPL seasons 1–9 (2008–2016) and tested on season 10 (2017). Predictions are demonstrated on seasons 11–12 (2018–2019).

---

## 📂 Project Structure

```
├── First_Innings_Score_Prediction_-_IPL.ipynb   # Main notebook
├── dataset/
│   └── ipl.csv                                  # Ball-by-ball IPL dataset
└── README.md
```

---

## 📊 Dataset

- **Source**: Ball-by-ball IPL match data
- **File**: `dataset/ipl.csv`
- **Seasons covered**: IPL 2008 – 2019
- **Teams included** (consistent teams only):
  - Chennai Super Kings, Mumbai Indians, Kolkata Knight Riders
  - Royal Challengers Bangalore, Sunrisers Hyderabad
  - Delhi Daredevils, Kings XI Punjab, Rajasthan Royals

> **Note**: The dataset is not included in this repo due to size. Download it from [Kaggle - IPL Ball by Ball](https://www.kaggle.com/datasets/manasgarg/ipl) and place it in the `dataset/` folder.

---

## ⚙️ Features Used

| Feature | Description |
|---|---|
| `bat_team` | Batting team |
| `bowl_team` | Bowling team |
| `overs` | Overs completed (min 5) |
| `runs` | Runs scored so far |
| `wickets` | Wickets fallen (0–10) |
| `runs_in_prev_5` | Runs scored in last 5 overs |
| `wickets_in_prev_5` | Wickets lost in last 5 overs |

---

## 🧹 Data Preprocessing

- Removed irrelevant columns: `mid`, `venue`, `batsman`, `bowler`, `striker`, `non-striker`
- Kept only 8 consistent franchise teams
- Removed first 5 overs data (too early to predict reliably)
- Converted `date` column to datetime
- Applied One-Hot Encoding on team names
- Train/test split based on year: trained on ≤ 2016, tested on ≥ 2017

---

## 🤖 Models Compared

| Model | Notes |
|---|---|
| Linear Regression | Best performing — used as final model |
| Decision Tree Regressor | Overfits, higher error |
| Random Forest Regressor | Better than Decision Tree, slightly worse than LR |
| AdaBoost (with LR base) | Marginal improvement over plain LR |

**Linear Regression** gave the best MAE/RMSE and was selected as the final model.

---

## 🎯 Sample Predictions

| Match | Teams | Actual Score | Predicted Range |
|---|---|---|---|
| IPL S11 M13 | KKR vs DD | 200/9 | 190 – 205 |
| IPL S11 M39 | SRH vs RCB | 146/10 | 136 – 151 |
| IPL S12 M9 | MI vs KXIP | 176/7 | 166 – 181 |
| IPL S12 Elim | DD vs CSK | 147/9 | 137 – 152 |

---

## 🖥️ Interactive Predictor (ipywidgets)

The notebook includes an interactive widget at the end — no need to edit any code. Just use the sliders and dropdowns to select match conditions and click **Predict Score**.

**Constraints enforced:**
- Wickets capped at 10
- Runs in last 5 overs cannot exceed total runs
- Wickets in last 5 overs cannot exceed total wickets

```python
# Run this cell after building the model to launch the interactive predictor
import ipywidgets as widgets
# ... (see last cell in notebook)
```

---

## 🚀 Getting Started

### 1. Clone the repo

```bash
git clone https://github.com/vanshR18/Analysis-Projects.git
cd "Analysis-Projects/02_IPL First Innings Score Predictor"
```

### 2. Install dependencies

```bash
pip install -r requirements.txt
```

### 3. Add the dataset

Download `ipl.csv` from Kaggle and place it in the `dataset/` folder.

### 4. Run the notebook

```bash
jupyter notebook First_Innings_Score_Prediction_-_IPL.ipynb
```

---

## 📦 Requirements

```
pandas
numpy
scikit-learn
matplotlib
seaborn
ipywidgets
jupyter
```

---

## ⚠️ Limitations

- Model is trained on data up to 2019 — newer teams (e.g., Lucknow Super Giants, Gujarat Titans) are not supported
- Venue and toss data are not factored in
- Prediction accuracy is lower in early overs (before over 10)

---

## 📃 License

This project is open source and available under the [MIT License](LICENSE).
