"""
Exploratory Data Analysis (EDA) & Data Pipeline Template
Author: SpectraOne Solutions (https://spectraonesolutions.com)
Description: Production-ready Python template for automated data profiling and baseline modeling.
"""

import pandas as pd
import numpy as np

def run_automated_eda(df: pd.DataFrame) -> dict:
    """
    Performs quick health checks and exploratory analysis on a dataset.
    """
    print("=" * 60)
    print("📊 DATASET SUMMARY PROFILE")
    print("=" * 60)
    
    # 1. Basic Shape and Memory Usage
    rows, cols = df.shape
    memory_mb = df.memory_usage().sum() / (1024 * 1024)
    print(f"Total Rows: {rows} | Total Columns: {cols} | Memory: {memory_mb:.2f} MB\n")
    
    # 2. Missing Value Audit
    missing = df.isnull().sum()
    missing_pct = (missing / rows) * 100
    missing_report = pd.DataFrame({'Missing_Count': missing, 'Missing_%': missing_pct})
    missing_report = missing_report[missing_report['Missing_Count'] > 0]
    
    print("🔍 Missing Values Audit:")
    if not missing_report.empty:
        print(missing_report)
    else:
        print("No missing values detected.")
    print("-" * 60)
    
    # 3. Numeric Outlier Detection using IQR Method
    numeric_cols = df.select_dtypes(include=[np.number]).columns
    outlier_counts = {}
    
    for col in numeric_cols:
        q1 = df[col].quantile(0.25)
        q3 = df[col].quantile(0.75)
        iqr = q3 - q1
        lower_bound = q1 - 1.5 * iqr
        upper_bound = q3 + 1.5 * iqr
        outliers = df[(df[col] < lower_bound) | (df[col] > upper_bound)]
        outlier_counts[col] = len(outliers)
        
    print("🚨 Outlier Analysis (IQR Method):")
    for col, count in outlier_counts.items():
        if count > 0:
            print(f" - {col}: {count} potential outliers ({(count/rows)*100:.2f}%)")
    print("=" * 60)
    
    return {
        "shape": (rows, cols),
        "missing_summary": missing_report,
        "outlier_summary": outlier_counts
    }

if __name__ == "__main__":
    # Example test dataset
    np.random.seed(42)
    sample_data = {
        'customer_id': range(1001, 1101),
        'monthly_spend': np.random.normal(150, 45, 100),
        'tenure_months': np.random.randint(1, 48, 100),
        'churn': np.random.choice([0, 1], size=100, p=[0.8, 0.2])
    }
    # Introduce some test outliers and nulls
    sample_data['monthly_spend'][5] = 950.0  # outlier
    df_sample = pd.DataFrame(sample_data)
    df_sample.loc[10:14, 'monthly_spend'] = np.nan  # missing values
    
    run_automated_eda(df_sample)
