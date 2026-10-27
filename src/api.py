import os
from contextlib import asynccontextmanager
import pandas as pd
import mlflow.pyfunc
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from feast import FeatureStore
from src.tasks import generate_fraud_explanation

# Global state
store = None
model = None

@asynccontextmanager
async def lifespan(app: FastAPI):
    global store, model
    
    # 1. Fix: Dynamic Absolute Path for Feast
    current_dir = os.path.dirname(__file__)
    feast_repo_path = os.path.join(current_dir, "features")
    
    try:
        store = FeatureStore(repo_path=feast_repo_path)
        print("Feast Feature Store initialized successfully.")
    except Exception as e:
        print(f"Feast initialization warning: {e}")

    # MLflow Setup
    MLFLOW_TRACKING_URI = os.getenv("MLFLOW_TRACKING_URI", "http://mlflow-service:5000")
    mlflow.set_tracking_uri(MLFLOW_TRACKING_URI)
    
    try:
        model = mlflow.pyfunc.load_model("models:/fraud_xgboost_model/Production")
        print("Model loaded successfully from MLflow.")
    except Exception as e:
        print(f"Warning: Model not found in MLflow. Expected on first boot. Error: {e}")
        
    # 2. Fix: Yield control back to FastAPI application
    yield
    print("Shutting down API...")

# Initialize FastAPI with the modern lifespan context
app = FastAPI(title="Fraud Detection API", version="2.0.1", lifespan=lifespan)

class TransactionRequest(BaseModel):
    transaction_id: str

@app.post("/predict")
def predict(request: TransactionRequest):
    if not model or not store:
        raise HTTPException(status_code=503, detail="Model or Feature Store not fully initialized.")

    try:
        feast_response = store.get_online_features(
            features=[
                "transaction_features:income",
                "transaction_features:name_email_similarity",
                "transaction_features:payment_type",
                "transaction_features:device_os"
            ],
            entity_rows=[{"transaction_id": request.transaction_id}]
        )
        feature_df = feast_response.to_df()
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Feast retrieval failed: {e}")

    expected_columns = ["income", "name_email_similarity", "payment_type", "device_os"]
    
    try:
        model_input_df = feature_df[expected_columns]
        prediction = model.predict(model_input_df)
        prob = float(prediction[0])
        
        # Enqueue explanation only if high-risk threshold is breached
        if prob > 0.85:
            generate_fraud_explanation(
                request.transaction_id, 
                prob, 
                model_input_df.iloc[0].to_dict()
            )
            
        return {
            "transaction_id": request.transaction_id,
            "fraud_probability": prob
        }
    except KeyError as e:
        raise HTTPException(status_code=500, detail=f"Missing expected features from Feast: {e}")