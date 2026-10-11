from datetime import timedelta
from feast import Entity, FeatureView, Field, ValueType
from feast.infra.offline_stores.contrib.postgres_offline_store.postgres_source import PostgreSQLSource
from feast.types import Float32, String

transaction = Entity(name="transaction_id", value_type=ValueType.STRING, description="Transaction ID")

historical_fraud_data = PostgreSQLSource(
    name="historical_fraud_data",
    query="SELECT * FROM transactions",
    timestamp_field="event_timestamp",
)

transaction_feature_view = FeatureView(
    name="transaction_features",
    entities=[transaction],
    ttl=timedelta(days=365),
    schema=[
        Field(name="income", dtype=Float32),
        Field(name="name_email_similarity", dtype=Float32),
        Field(name="payment_type", dtype=String),
        Field(name="device_os", dtype=String),
    ],
    source=historical_fraud_data,
)