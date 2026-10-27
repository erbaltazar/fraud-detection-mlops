import os
from huey import RedisHuey
from groq import Groq

# Connect to the Upstash Redis instance
redis_host = os.getenv("FEAST_REDIS_HOST", "localhost:6379")
redis_password = os.getenv("FEAST_REDIS_PASSWORD", "")
connection_url = f"rediss://:{redis_password}@{redis_host}" if redis_password else f"redis://{redis_host}"

huey = RedisHuey('fraud_xai_queue', url=connection_url)
groq_client = Groq(api_key=os.getenv("GROQ_API_KEY"))

@huey.task(retries=3, retry_delay=10) # Retries mitigate Groq 429 Too Many Requests errors
def generate_fraud_explanation(transaction_id: str, fraud_probability: float, features: dict):
    prompt = (
        f"You are a financial risk analyst. Explain why a transaction with the following "
        f"features received a fraud probability score of {fraud_probability:.2f}.\n"
        f"Transaction ID: {transaction_id}\n"
        f"Features: {features}\n"
        f"Keep the explanation concise and professional to meet MAS FEAT guidelines."
    )

    try:
        chat_completion = groq_client.chat.completions.create(
            messages=[{"role": "user", "content": prompt}],
            model="llama3-8b-8192",
        )
        explanation = chat_completion.choices[0].message.content
        print(f"[XAI Result for {transaction_id}]: {explanation}")
        return explanation
    except Exception as e:
        print(f"Groq API error for {transaction_id}: {e}")
        raise e