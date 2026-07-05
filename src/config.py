from pathlib import Path

# Dynamically resolve the absolute path to the project root
ROOT_DIR = Path(__file__).resolve().parent.parent

# Define data directories
DATA_DIR = ROOT_DIR / "data" / "raw"
BASE_DATA_PATH = DATA_DIR / "Base.csv"

# In the future, we will add Kafka broker URLs, Feast repo paths, 
# and MLflow tracking URIs in this file.