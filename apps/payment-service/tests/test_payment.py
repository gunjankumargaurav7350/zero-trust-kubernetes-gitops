import pytest
from httpx import AsyncClient, ASGITransport
import sys
import os

sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), "..")))
from src.app import app


@pytest.mark.asyncio
async def test_health_probes():
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as client:
        resp1 = await client.get("/healthz")
        assert resp1.status_code == 200
        assert resp1.json()["status"] == "healthy"

        resp2 = await client.get("/ready")
        assert resp2.status_code == 200
        assert resp2.json()["status"] == "ready"


@pytest.mark.asyncio
async def test_process_payment_success():
    payload = {
        "account_id": "acct-test-001",
        "amount": 250.75,
        "currency": "USD",
        "payment_method": "vault_token_sample"
    }
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as client:
        response = await client.post("/v1/payments", json=payload)
        assert response.status_code == 201
        data = response.json()
        assert "transaction_id" in data
        assert data["status"] == "SETTLED"
        assert data["amount"] == 250.75
        assert data["currency"] == "USD"


@pytest.mark.asyncio
async def test_process_payment_idempotency():
    payload = {
        "account_id": "acct-test-002",
        "amount": 50.00,
        "currency": "EUR",
        "payment_method": "token_abc"
    }
    headers = {"Idempotency-Key": "idemp-key-unique-12345"}

    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as client:
        # First call
        resp1 = await client.post("/v1/payments", json=payload, headers=headers)
        assert resp1.status_code == 201
        tx1 = resp1.json()["transaction_id"]

        # Duplicate call with identical idempotency key
        resp2 = await client.post("/v1/payments", json=payload, headers=headers)
        assert resp2.status_code == 201
        tx2 = resp2.json()["transaction_id"]

        # Transaction IDs must match (no double charge)
        assert tx1 == tx2


@pytest.mark.asyncio
async def test_process_payment_unsupported_currency():
    payload = {
        "account_id": "acct-test-003",
        "amount": 10.00,
        "currency": "XYZ",
        "payment_method": "token_abc"
    }
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as client:
        response = await client.post("/v1/payments", json=payload)
        assert response.status_code == 400
