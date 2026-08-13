#!/bin/bash

[ -f .env.example ] && [ ! -f .env ] && cp .env.example .env
[ -f pyproject.toml ] && uv sync
