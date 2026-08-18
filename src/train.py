import os
from pathlib import Path
import joblib
import pandas as pd
from xgboost import XGBClassifier
from sklearn.metrics import classification_report, roc_auc_score, average_precision_score

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
        n_estimators=100,          # Number of decision trees
        max_depth=6,               # Maximum tree depth to prevent overfitting
        learning_rate=0.1,         # Step size shrinkage
        scale_pos_weight=scale_weight,  # Penalize missing a fraud case heavily
        enable_categorical=True,   # Native categorical support for pandas category dtypes
        tree_method="hist",        # Fast histogram-based tree building
        random_state=42,
        eval_metric="aucpr"        # Optimize for Area Under Precision-Recall Curve
    )
    
    print("Fitting model to training data...")
    model.fit(X_train, y_train)
    print("Model training complete.")
    
    return model

def evaluate_model(model: XGBClassifier, X_test: pd.DataFrame, y_test: pd.Series):
    """
    Evaluates the trained model against the quarantined test dataset.
    """
    print("\n" + "="*30)
    print("EVALUATING MODEL PERFORMANCE")
    print("="*30)
    
    # Raw binary predictions (0 or 1)
    y_pred = model.predict(X_test)
    # Probability scores (0.0 to 1.0)
    y_prob = model.predict_proba(X_test)[:, 1]
    
    # Financial metrics that matter in production
    roc_auc = roc_auc_score(y_test, y_prob)
    pr_auc = average_precision_score(y_test, y_prob)
    
    print(f"ROC-AUC Score: {roc_auc:.4f}")
    print(f"PR-AUC (Precision-Recall) Score: {pr_auc:.4f}\n")
    print("Classification Report:")
    print(classification_report(y_test, y_pred, digits=4))

def save_model_artifact(model: XGBClassifier, output_dir: Path = Path("models")):
    """
    Serializes the trained model object to disk.
    """
    output_dir.mkdir(parents=True, exist_ok=True)
    model_path = output_dir / "xgboost_fraud_model.joblib"
    joblib.dump(model, model_path)
    print(f"\nModel artifact saved successfully to: {model_path}")