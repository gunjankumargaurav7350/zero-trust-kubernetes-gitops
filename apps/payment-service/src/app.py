import os
import uuid
import logging
from typing import Dict, Optional
from datetime import datetime, timezone
from contextlib import asynccontextmanager

from fastapi import FastAPI, Header, HTTPException, status
from pydantic import BaseModel, Field

logging.basicConfig(level=logging.INFO, format="%(asctime)s [%(levelname)s] %(name)s: %(message)s")
logger = logging.getLogger("payment-service")

SECRET_MOUNT_PATH = os.getenv("SECRET_MOUNT_PATH", "/mnt/secrets-store")
API_KEY_FILE = os.path.join(SECRET_MOUNT_PATH, "api-key")

# In-memory transaction and idempotency store
transactions: Dict[str, dict] = {}
idempotency_records: Dict[str, str] = {}


@asynccontextmanager
async def lifespan(app: FastAPI):
    # Verify secret mount if present
    if os.path.exists(API_KEY_FILE):
        logger.info("Key Vault CSI secrets store mounted successfully at %s", API_KEY_FILE)
    else:
        logger.info("Running in fallback credentials mode (secret volume not mounted).")
    yield


app = FastAPI(
    title="Zero-Trust Payment Gateway Service",
    description="Secure payment microservice with Workload Identity and CSI Secrets Store integration",
    version="1.0.0",
    lifespan=lifespan,
)


class PaymentRequest(BaseModel):
    account_id: str = Field(..., min_length=4, max_length=64, example="acct-user-9921")
    amount: float = Field(..., gt=0, example=120.00)
    currency: str = Field(..., min_length=3, max_length=3, example="USD")
    payment_method: str = Field(..., example="card_token_vault_4821")
    description: Optional[str] = Field(None, max_length=256)


class PaymentResponse(BaseModel):
    transaction_id: str
    account_id: str
    amount: float
    currency: str
    status: str
    processed_at: str


@app.get("/healthz", status_code=status.HTTP_200_OK)
async def liveness():
    return {"status": "healthy", "service": "payment-service"}


@app.get("/ready", status_code=status.HTTP_200_OK)
async def readiness():
    return {"status": "ready"}


@app.post("/v1/payments", response_model=PaymentResponse, status_code=status.HTTP_201_CREATED)
async def process_payment(
    payment: PaymentRequest,
    idempotency_key: Optional[str] = Header(None, alias="Idempotency-Key")
):
    # Idempotency check to prevent duplicate charges
    if idempotency_key and idempotency_key in idempotency_records:
        existing_tx_id = idempotency_records[idempotency_key]
        logger.info("Idempotent request detected. Returning existing transaction %s", existing_tx_id)
        return transactions[existing_tx_id]

    currency = payment.currency.upper()
    if currency not in ("USD", "EUR", "GBP", "INR", "CAD"):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Unsupported currency: {currency}"
        )

    tx_id = f"tx_{uuid.uuid4().hex[:12]}"
    now = datetime.now(timezone.utc).isoformat()

    record = {
        "transaction_id": tx_id,
        "account_id": payment.account_id,
        "amount": round(payment.amount, 2),
        "currency": currency,
        "status": "SETTLED",
        "processed_at": now,
    }

    transactions[tx_id] = record

    if idempotency_key:
        idempotency_records[idempotency_key] = tx_id

    # PCI-DSS compliant audit log (no sensitive payment credentials logged)
    logger.info("Payment settled: tx=%s, account=%s, amount=%.2f %s", tx_id, payment.account_id, payment.amount, currency)
    return record


@app.get("/v1/payments/{transaction_id}", response_model=PaymentResponse)
async def get_payment(transaction_id: str):
    if transaction_id not in transactions:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Transaction not found")
    return transactions[transaction_id]
