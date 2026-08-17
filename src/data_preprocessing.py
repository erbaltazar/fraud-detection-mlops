import pandas as pd
from sklearn.model_selection import train_test_split

def split_and_stratify_data(df: pd.DataFrame, target_col: str = 'fraud_bool'):
    """
    Separates features from the target and performs a stratified split.
    """
    print("\n" + "="*30)
    print("SPLITTING DATASET")
    print("="*30)
    
    X = df.drop(columns=[target_col])
    y = df[target_col]
    
    X_train, X_test, y_train, y_test = train_test_split(
        X, y, 
        test_size=0.2, 
        random_state=42, 
        stratify=y  
    )
    
    print(f"Training Features Shape: {X_train.shape}")
    print(f"Testing Features Shape: {X_test.shape}")
    
    return X_train, X_test, y_train, y_test


def format_categorical_columns(X_train: pd.DataFrame, X_test: pd.DataFrame):
    """
    Converts object/string columns to Pandas 'category' datatypes
    for XGBoost native categorical support.
    """
    print("\n" + "="*30)
    print("FORMATTING CATEGORICAL DATA")
    print("="*30)
    
    categorical_cols = X_train.select_dtypes(include=['object', 'string']).columns.tolist()
    print(f"Identified Categorical Columns: {categorical_cols}")
    
    for col in categorical_cols:
        X_train[col] = X_train[col].astype('category')
        X_test[col] = X_test[col].astype('category')
        
    print("Categorical conversion complete.")
    return X_train, X_test