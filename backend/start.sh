#!/bin/bash
set -e

echo "--- Populando banco com dados de seed ---"
python seed.py

echo "--- Iniciando servidor ---"
uvicorn app.main:app --host 0.0.0.0 --port "${PORT:-8000}"
