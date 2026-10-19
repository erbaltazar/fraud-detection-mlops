import time
import json
import pandas as pd
from kafka import KafkaProducer
import os
import tempfile

class TokenBucketRateLimiter:
    def __init__(self, rate_limit_per_second):
        self.rate_limit = rate_limit_per_second
        self.tokens = rate_limit_per_second
        self.last_updated = time.time()

    def consume(self):
        while self.tokens < 1:
            now = time.time()
            elapsed = now - self.last_updated
            self.tokens = min(self.rate_limit, self.tokens + elapsed * self.rate_limit)
            self.last_updated = now
            if self.tokens < 1:
                time.sleep(0.1)
        self.tokens -= 1

def create_temp_cert(env_var_name, file_name):
    cert_data = os.getenv(env_var_name)
    if not cert_data:
        raise ValueError(f"Missing environment variable from Infisical: {env_var_name}")
    
    # Handle potential escaped newlines from the vault
    cert_data = cert_data.replace('\\n', '\n')
    
    temp_dir = tempfile.gettempdir()
    file_path = os.path.join(temp_dir, file_name)
    with open(file_path, 'w') as f:
        f.write(cert_data)
    return file_path

def main():
    print("Constructing SSL certificates from environment variables...")
    ca_path = create_temp_cert("KAFKA_CA_PEM", "ca.pem")
    cert_path = create_temp_cert("KAFKA_SERVICE_CERT", "service.cert")
    key_path = create_temp_cert("KAFKA_SERVICE_KEY", "service.key")

    producer = KafkaProducer(
        bootstrap_servers=os.getenv("KAFKA_BOOTSTRAP_SERVERS"),
        security_protocol="SSL",
        ssl_cafile=ca_path,
        ssl_certfile=cert_path,
        ssl_keyfile=key_path,
        value_serializer=lambda v: json.dumps(v).encode('utf-8')
    )

    print("Loading Feedzai dataset...")
    df = pd.read_csv('data/raw/Base.csv')
    
    limiter = TokenBucketRateLimiter(rate_limit_per_second=5)
    
    print("Starting rate-limited data stream...")
    for index, row in df.iterrows():
        limiter.consume()
        payload = row.to_dict()
        producer.send('transactions_topic', value=payload)
        
        if index % 10 == 0:
            print(f"Streamed {index} records safely...")
            
    producer.flush()

if __name__ == "__main__":
    main()