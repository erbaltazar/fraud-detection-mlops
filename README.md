End-to-End Real-Time Fraud Detection (MLOps)

This repository contains an end-to-end Machine Learning pipeline simulating a high-throughput financial system, designed for real-time fraud detection.

🏗️ Architectural Overview (Planned)

The final architecture will be a fully containerized, local Kubernetes deployment utilizing:

Message Broker: Redpanda

Feature Store: Feast (Redis & PostgreSQL)

Model Registry: MLflow

Model Serving: FastAPI + XGBoost

CI/CD: GitHub Actions + ArgoCD

🚀 Current Progress: Phase 1 (Foundation)

Currently, the pipeline establishes a robust, OS-agnostic data ingestion and profiling baseline using Python.

Local Setup

This project uses uv for dependency management to ensure strict lockfile resolution.

Clone the repository.

Initialize the environment:

uv venv
source .venv/bin/activate  # Or .venv\Scripts\activate on Windows
uv pip install -r requirements.txt


Download the Feedzai Bank Account Fraud dataset and place Base.csv inside data/raw/.

Run the baseline profiler:

python src/main.py


📜 License

This project is licensed under the MIT License.