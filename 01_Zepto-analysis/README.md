# 📦 Zepto Inventory Data Analysis

<div align="center">

![Python](https://img.shields.io/badge/Python-3.8+-blue?style=for-the-badge&logo=python)
![Pandas](https://img.shields.io/badge/Pandas-Data%20Analysis-green?style=for-the-badge)
![Plotly](https://img.shields.io/badge/Plotly-Interactive%20Viz-purple?style=for-the-badge)
![PowerBI](https://img.shields.io/badge/PowerBI-Dashboard-yellow?style=for-the-badge)
![SQL](https://img.shields.io/badge/SQL-MySQL-orange?style=for-the-badge)

**A comprehensive data analysis project exploring Zepto's inventory optimization, pricing strategy, and revenue drivers.**

[Project Overview](#-project-overview) • [Key Insights](#-key-insights) • [Analysis Problems](#-analysis-problems) • [Project Structure](#-project-structure) 

</div>

---

## 🎯 Project Overview

This project analyzes Zepto's inventory dataset to uncover business insights around:
- **Revenue optimization** across product categories
- **Pricing strategy effectiveness** and discount impact
- **Inventory management** and stock-out risk
- **Demand patterns** and product performance
- **Category-level trends** and inefficiencies

The analysis combines **exploratory data analysis (EDA)**, **statistical insights**, and **business problem identification** to provide actionable recommendations for inventory optimization and revenue growth.

### 📊 Dataset Overview
- **Total Records**: 1000+ products
- **Key Metrics**: Price, Quantity, Discount %, Availability, Revenue
- **Time Period**: Current inventory snapshot
- **Data Quality**: Cleaned and preprocessed

---

## 💡 Key Insights

### Revenue Drivers
- 📈 **Top performers** account for significant revenue concentration
- 💰 **Price sensitivity**: Correlation between discount % and sales volume
- 🎯 **Category performance**: Revenue varies significantly by product category

### Inventory Challenges
- ⚠️ **Stock-out risk**: Products with high demand but low availability
- 📦 **Inefficient allocation**: Uniform stock levels despite varying demand
- 🔄 **Inventory turnover**: Wide variance in stock movement rates

### Pricing Insights
- 💵 **Over-discounting**: Some products sacrifice margin without boosting sales
- 📊 **Price gaps**: Opportunities for premium positioning
- 🏷️ **Price perception**: Price-per-gram analysis reveals inefficiencies

---

## 🔍 Analysis Problems & Solutions

### **Problem 1️⃣: Stock-Out Risk Assessment**
Identifying products vulnerable to stockouts due to low inventory + high demand.
- **Metric**: Available Quantity vs. Ordered Quantity
- **Action**: Priority replenishment list

### **Problem 2️⃣: Discount Effectiveness**
Evaluating whether discounts are driving revenue or just eroding margins.
- **Analysis**: Correlation between discount % and quantity sold
- **Finding**: Some discounts drive volume; others don't justify the margin loss

### **Problem 3️⃣: Revenue Concentration**
Analyzing dependency on top-performing products.
- **Metric**: Revenue share distribution
- **Risk**: Business vulnerable to Top-N product fluctuations

### **Problem 4️⃣: Price Positioning**
Identifying over/underpriced products using price-per-gram analysis.
- **Tool**: Relative pricing analysis within categories
- **Opportunity**: Premium positioning for underpriced products

### **Problem 5️⃣: Inefficient Inventory**
Detecting products with high stock but low sales (capital blocked).
- **Metric**: Available Quantity vs. Sales Velocity
- **Action**: Markdown or discontinuation candidates

### **Problem 6️⃣: Abnormal Ordering Behavior**
Flagging bulk orders and unusual demand patterns.
- **Analysis**: Outlier detection in quantity ordered
- **Risk**: Supply chain strain, stockout cascades

### **Problem 7️⃣: Over-Discounting Trap**
Products giving deep discounts without proportional volume gains.
- **Metric**: Discount % vs. Quantity elasticity
- **Recommendation**: Reduce discounts or improve product positioning

### **Problem 8️⃣: Low Demand Despite Discounts**
Products with discounts but still showing weak demand.
- **Signal**: Product-market fit issue, not pricing
- **Action**: Product review or discontinuation

### **Problem 9️⃣: Demand Skewness**
Assessing concentration risk when few products drive majority revenue.
- **Metric**: Pareto analysis (80/20 rule)
- **Strategic**: Diversification needed

### **Problem 🔟: Packaging Inefficiency**
Analyzing weight variations and inconsistent value perception.
- **Analysis**: Grams vs. Price relationship
- **Opportunity**: Standardized packaging improvements

### **Problem 1️⃣1️⃣: Bulk Buying Behavior Risk**
Detecting extreme volume orders causing supply chain stress.
- **Threshold**: Orders > 50 units flagged
- **Action**: Supply planning adjustment

### **Problem 1️⃣2️⃣: Poor Inventory Allocation**
Same stock levels across products despite different demand profiles.
- **Analysis**: Inventory vs. Sales correlation
- **Optimization**: Data-driven allocation formula

### **Problem 1️⃣3️⃣: Price Sensitivity Gap**
Missing elasticity data for price-demand relationship.
- **Data Need**: Historical price × quantity matrix
- **Future**: Elasticity modeling

### **Problem 1️⃣4️⃣: Category-Level Inefficiency**
Limited category diversity reducing strategic flexibility.
- **Observation**: Current data shows limited category spread
- **Opportunity**: Cross-category cannibalization analysis once more categories added

---

## 📁 Project Structure

```
zepto-analysis/
│
├── README.md                          # Project documentation
├── requirements.txt                   # Python dependencies
│
├── data/
│   ├── raw/
│   │   └── zepto_v2.csv              
├── notebooks/
│   └── zepto-analysis-with-problem-statements.ipynb  # Complete analysis
│
├── sql/
│   ├── inventory_queries.sql         # Stock-out risk queries
│   ├── revenue_queries.sql           # Revenue analysis queries
│   ├── discount_queries.sql          # Discount effectiveness queries
│   ├── pricing_queries.sql           # Price analysis queries
│   └── category_queries.sql          # Category-level analysis
│
├── dashboard/
│   ├── zepto_dashboard.pbix          # PowerBI dashboard file
│   └── dashboard_design.md           # Dashboard documentation
│
└── outputs/
    ├── Report_zepto.html             # ydata profiling report
    ├── visualizations/               # Exported charts
    └── insights_summary.pdf          # Executive summary
```

---

## 📊 Analysis Workflow

```
┌─────────────────┐
│  Raw Data       │ (zepto_v2.csv)
└────────┬────────┘
         │
         ↓
┌─────────────────────────┐
│  Data Cleaning & QA     │ Remove duplicates, check nulls
└────────┬────────────────┘
         │
         ↓
┌──────────────────────────┐
│  Feature Engineering     │ Create revenue, discounts, ratios
└────────┬─────────────────┘
         │
         ↓
┌──────────────────────────┐
│  Exploratory Analysis    │ Visualizations, distributions
└────────┬─────────────────┘
         │
         ↓
┌──────────────────────────┐
│  Problem Identification  │ 14 business problems identified
└────────┬─────────────────┘
         │
         ↓
┌──────────────────────────┐
│  SQL Queries & Export    │ For PowerBI dashboard
└────────┬─────────────────┘
         │
         ↓
┌──────────────────────────┐
│  PowerBI Dashboard       │ Interactive business intelligence
└──────────────────────────┘
```

---

## 🎨 Visualization Highlights

### Charts & Graphs Included
- 📊 **Revenue by Category** - Stacked bar charts
- 📈 **Top 20 Products** - Revenue performance
- 💹 **Discount vs. Demand** - Scatter plot correlation
- 📉 **Price Distribution** - Histogram analysis
- 🎯 **Category Performance** - Multiple KPI charts
- 🔗 **Price per Gram** - Efficiency metrics

### Interactive Dashboards (PowerBI)
- Real-time filtering by category, price range
- Drill-down product analysis
- KPI cards for revenue, inventory, margins
- Trend analysis and forecasting visuals

---

## 🔧 Key Technologies

| Technology | Purpose |
|-----------|---------|
| **Python** | Data processing & analysis |
| **Pandas** | Data manipulation |
| **Plotly** | Interactive visualizations |
| **Seaborn/Matplotlib** | Statistical plots |
| **ydata-profiling** | Automated EDA reports |
| **SQL** | Database queries |
| **PowerBI** | Interactive dashboards |
| **Jupyter** | Exploratory analysis |

---

## 📈 Key Metrics Tracked

### Operational Metrics
- **Stock Availability**: % of products in stock
- **Inventory Turnover**: Quantity sold vs. available
- **Stock-out Risk Score**: Products at risk

### Financial Metrics
- **Total Revenue**: Sum of all sales
- **Revenue per Product**: Average product revenue
- **Revenue Concentration**: Pareto distribution
- **Margin Impact**: Discount effect on profitability

### Demand Metrics
- **Demand Distribution**: Quantity sold patterns
- **Demand Elasticity**: Price sensitivity (to be modeled)
- **Bulk Order Frequency**: % orders > 50 units
- **Demand Skewness**: Dependency on top products

### Pricing Metrics
- **Average Discount %**: Category and overall
- **Price per Unit/Gram**: Value positioning
- **Price Range**: Min-max within categories
- **Discount Effectiveness**: Impact on sales volume

---


## 📊 Expected Outcomes

### Business Impact
- ✅ **Optimized Pricing** → 5-10% margin improvement
- ✅ **Reduced Stockouts** → Better inventory allocation
- ✅ **Improved Revenue** → Focus on high-ROI products
- ✅ **Data-driven Decisions** → Real-time insights

### Deliverables
- 📋 14+ actionable business insights
- 📊 Interactive PowerBI dashboard
- 🔍 SQL query library for analysis
- 📈 Executive summary report

---

## 👤 Author & Contact

**Created as a comprehensive data analysis portfolio project**

### Skills Demonstrated
- Data Analysis & Visualization
- Statistical Analysis
- Business Intelligence
- Python Programming
- SQL Database Queries
- Dashboard Development

---

## 📝 License

This project is open source and available under the MIT License.

---

## 🙏 Acknowledgments

- **Data Source**: Zepto Inventory Dataset (Kaggle)
- **Libraries**: Pandas, Plotly, ydata-profiling communities
- **Inspiration**: Real-world retail analytics challenges

---

## 📞 Support & Feedback

Found an issue or have suggestions? Feel free to:
- 🐛 Report bugs
- 💡 Suggest improvements
- 📧 Share feedback

---

<div align="center">

**⭐ If you found this analysis helpful, please star the repository!**

Made with ❤️ for data enthusiasts

</div>
