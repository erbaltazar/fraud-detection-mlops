from config import BASE_DATA_PATH
from data_loader import load_csv
from data_profiler import print_basic_stats, print_target_distribution
from data_preprocessing import split_and_stratify_data, format_categorical_columns
from train import train_xgboost_model, evaluate_model, save_model_artifact

def main():
    """
    Orchestrates data ingestion, preprocessing, training, evaluation, and serialization.
    """
    # 1. Ingestion Phase
    df = load_csv(BASE_DATA_PATH)
    
    # 2. Profiling Phase
    print_basic_stats(df)
    print_target_distribution(df, target_col='fraud_bool')
    
    # 3. Preprocessing Phase
    # Isolate the test data to prevent data leakage
    X_train, X_test, y_train, y_test = split_and_stratify_data(df)
    
    # Convert text columns to internal pandas dictionaries for XGBoost
    X_train, X_test = format_categorical_columns(X_train, X_test)
    
    # 4. Training Phase
    # Feed the 800,000 training rows and answers into the algorithm
    model = train_xgboost_model(X_train, y_train)
    
    # 5. Evaluation Phase
    # Grade the model against the 200,000 hidden test rows
    evaluate_model(model, X_test, y_test)
    
    # 6. Artifact Serialization
    # Save the compiled model to disk
    save_model_artifact(model)

if __name__ == "__main__":
    main()