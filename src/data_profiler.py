import pandas as pd

def print_basic_stats(df: pd.DataFrame) -> None:
    """Prints the total rows, columns, and missing values."""
    print("\n" + "="*30)
    print("DATASET OVERVIEW")
    print("="*30)
    print(f"Total Rows: {df.shape[0]:,}")
    print(f"Total Columns: {df.shape[1]}")
    
    missing_values = df.isnull().sum().sum()
    print(f"Total Missing Values: {missing_values}")

def print_target_distribution(df: pd.DataFrame, target_col: str = 'fraud_bool') -> None:
    """Calculates and prints the class distribution of the target variable."""
    if target_col in df.columns:
        print("\n" + "="*30)
        print(f"TARGET DISTRIBUTION ({target_col})")
        print("="*30)
        counts = df[target_col].value_counts()
        percentages = df[target_col].value_counts(normalize=True) * 100
        
        dist_df = pd.DataFrame({
            'Count': counts,
            'Percentage (%)': percentages.round(2)
        })
        print(dist_df)
    else:
        print(f"\nTarget column '{target_col}' not found in dataset.")

def print_head(df: pd.DataFrame, n: int = 3) -> None:
    """Prints the first n rows, ensuring all columns are visible."""
    print("\n" + "="*30)
    print(f"FIRST {n} ROWS")
    print("="*30)
    pd.set_option('display.max_columns', None) 
    print(df.head(n))