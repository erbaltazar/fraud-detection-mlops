from config import BASE_DATA_PATH
from data_loader import load_csv
from data_profiler import print_basic_stats, print_target_distribution, print_head

def main():
    """
    Entry point for the MLOps pipeline.
    Orchestrates data loading and profiling.
    """
    # 1. Ingestion Phase
    df = load_csv(BASE_DATA_PATH)
    
    # 2. Profiling Phase
    print_basic_stats(df)
    print_target_distribution(df, target_col='fraud_bool')
    print_head(df, n=3)

if __name__ == "__main__":
    main()