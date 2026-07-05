import pandas as pd
import sys
from pathlib import Path

def load_csv(file_path: Path) -> pd.DataFrame:
    """
    Safely loads a CSV file into a pandas DataFrame.
    Exits the program with an error code if the file is missing.
    """
    print(f"Attempting to load data from: {file_path}")
    
    if not file_path.exists():
        print(f"Error: Could not locate the dataset at {file_path}")
        # Exiting with code 1 is critical for CI/CD pipelines to know it failed
        sys.exit(1)

    print("Loading data... (This might take a few seconds for large files)")
    return pd.read_csv(file_path)