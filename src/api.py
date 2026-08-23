# src/api.py
import joblib
import pandas as pd
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel, ConfigDict

app = FastAPI(title="Enterprise Fraud Detection API", version="1.0.0")

try:
    print("Loading XGBoost model artifact...")
    model = joblib.load("models/xgboost_fraud_model.joblib")
    # Extract the exact column names and order the model saw during training
    EXPECTED_COLUMNS = model.feature_names_in_
    print("Model loaded successfully.")
except Exception as e:
    print(f"CRITICAL ERROR: Could not load model. {e}")
    model = None
    EXPECTED_COLUMNS = []

class TransactionPayload(BaseModel):
    model_config = ConfigDict(extra='allow')
    income: float
    name_email_similarity: float
    payment_type: str
    device_os: str

@app.post("/predict")
def predict_fraud(payload: TransactionPayload):
    if model is None:
        raise HTTPException(status_code=500, detail="Inference engine is offline.")

    # 1. Unpack JSON to DataFrame
    input_data = payload.model_dump()
    df = pd.DataFrame([input_data])
    
    # 2. Schema Enforcement: Force the DataFrame to match the training columns exactly.
    # Any missing columns from the payload will be filled with NaN.
    # Any extra columns sent by the client will be dropped.
    df = df.reindex(columns=EXPECTED_COLUMNS)
    
    # 3. Categorical Formatting
    categorical_cols = ['payment_type', 'employment_status', 'housing_status', 'source', 'device_os']
    for col in categorical_cols:
        if col in df.columns:
            df[col] = df[col].astype('category')

    # 4. Math Execution
    try:
        probability = float(model.predict_proba(df)[0, 1])
        is_fraud = int(probability > 0.5)

        return {
            "status": "blocked" if is_fraud else "approved",
            "fraud_probability": round(probability, 4)
        }
    except Exception as e:
        raise HTTPException(status_code=400, detail=f"Inference failed. Error: {str(e)}")

# Add a health check endpoint for Kubernetes
@app.get("/health")
def health_check():
    if model is not None:
        return {"status": "healthy"}
    raise HTTPException(status_code=503, detail="Model not loaded")