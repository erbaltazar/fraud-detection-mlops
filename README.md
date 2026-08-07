# End-to-End Real-Time Fraud Detection (MLOps)

This repository contains an end-to-end Machine Learning pipeline simulating a high-throughput financial system, designed for real-time fraud detection.

## 🏗️ Architectural Overview (Phase 3 Evolution)

To maintain a strict **$0.00 FinOps constraint** and protect the underlying Always Free ARM node from resource exhaustion, heavy stateful workloads have been offloaded to external managed services via APIs.

*   **Compute & Orchestration:** Oracle Cloud Infrastructure (OCI) Free Tier (ARM Ampere A1, 2 OCPUs, 12GB RAM) running K3s.
*   **Message Broker:** Upstash Serverless Kafka (Free Tier)
*   **Feature Store:** Feast (Backed by Upstash Redis & Neon Serverless PostgreSQL)
*   **Model Registry:** MLflow (Using Neon PostgreSQL for backend storage)
*   **Model Serving:** FastAPI + XGBoost
*   **Explainable AI (XAI):** Groq API Free Tier running Llama 3
*   **CI/CD:** GitHub Actions (Multi-Arch) + ArgoCD
*   **Infrastructure as Code:** Terraform (State managed via HCP Terraform Free Tier)
*   **Security & Secrets Management:** Infisical (Cloud Vault)

## 🚀 Current Progress: Phase 2 (Secure Cloud Infrastructure & IaC)

The local Python baseline has been successfully refactored into a modular, production-grade cloud architecture.

*   **VCN Established:** Strict `10.0.0.0/16` isolated cloud network deployed to the `ap-tokyo-1` region.
*   **Zero-Trust Ingress:** Cloud firewalls hardcoded via Terraform variables to explicitly reject all global traffic, allowing SSH and K3s API access only from the authenticated developer IP.
*   **GitOps Pipeline:** HCP Terraform webhook integration established to trigger automated infrastructure runs upon push to the `main` branch.

## 🛠️ Local Setup (Phase 1 Baseline)

This project uses `uv` for dependency management to ensure strict lockfile resolution and to bypass Windows/Linux encoding anomalies during Docker builds.

1.  Clone the repository.
2.  Initialize the environment:

    ```bash
    uv venv
    source .venv/bin/activate  # Or .venv\Scripts\activate on Windows
    uv pip install -r requirements.txt
    ```

3.  Download the Kaggle Feedzai Bank Account Fraud dataset and place `Base.csv` inside `data/raw/`.
4.  Run the baseline profiler:

    ```bash
    python src/main.py
    ```

## 📜 License

This project is licensed under the MIT License.
