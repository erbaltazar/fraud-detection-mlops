import time
import json
import pandas as pd
from kafka import KafkaProducer
import os

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
                time.sleep(0.1) # Briefly sleep to prevent CPU pegging
        self.tokens -= 1

def main():
    # Aiven Kafka connection configuration
    producer = KafkaProducer(
        bootstrap_servers=os.getenv("KAFKA_BOOTSTRAP_SERVERS"),
        security_protocol="SSL",
        ssl_cafile="ca.pem",
        ssl_certfile="service.cert",
        ssl_keyfile="service.key",
        value_serializer=lambda v: json.dumps(v).encode('utf-8')
    )

    print("Loading Feedzai dataset...")
    df = pd.read_csv('data/raw/Base.csv')
    
    # Hard limit to 5 transactions per second
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