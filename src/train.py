# src/train.py (Snippet)
import pandas as pd
from xgboost import XGBClassifier

def train_xgboost_model(X_train: pd.DataFrame, y_train: pd.Series) -> XGBClassifier:
    """
    Initializes and fits an XGBoost classifier with settings
    tailored for imbalanced financial tabular data.
    """
    print("\n" + "="*30)
    print("TRAINING XGBOOST MODEL")
    print("="*30)
    
    # 1. Calculate class imbalance ratio
    neg_count = (y_train == 0).sum()
    pos_count = (y_train == 1).sum()
    scale_weight = neg_count / pos_count
    print(f"Class Imbalance Ratio (scale_pos_weight): {scale_weight:.2f}")

    # 2. Instantiate XGBoost Classifier
    model = XGBClassifier(
        n_estimators=100,          
        max_depth=6,               
        learning_rate=0.1,         
        scale_pos_weight=scale_weight,  
        enable_categorical=True,   
        tree_method="hist",        
        random_state=42,
        eval_metric="aucpr"        
    )
    
    print("Fitting model to training data...")
    model.fit(X_train, y_train)
    print("Model training complete.")
    
    return model