#!/bin/bash

if [ -f requirements.txt ]; then 
    echo "Installing production requirements.txt..."
    python -m pip install -r requirements.txt
fi

if [ -f requirements.dev.txt ]; then 
    echo "Installing development requirements.txt..."
    python -m pip install -r requirements.dev.txt
fi

if [ -f .env.example ] && [ ! -f .env ]; then
    echo "Creating .env file from .env.example..."
    cp .env.example .env
fi
