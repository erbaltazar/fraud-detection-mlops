# src/main.py
from config import BASE_DATA_PATH
from data_loader import load_csv
from data_profiler import print_basic_stats, print_target_distribution
from data_preprocessing import split_and_stratify_data

def main():
    """
    Entry point for the MLOps pipeline.
    Orchestrates data ingestion, profiling, and preprocessing.
    """
    # 1. Ingestion Phase
    df = load_csv(BASE_DATA_PATH)
    
    # 2. Profiling Phase 
    print_basic_stats(df)
    print_target_distribution(df, target_col='fraud_bool')
    
    # 3. Data Preprocessing Phase
    X_train, X_test, y_train, y_test = split_and_stratify_data(df)

if __name__ == "__main__":
    main()