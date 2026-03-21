# On part d'une image Python légère
FROM python:3.11-slim

# On crée un dossier de travail dans le conteneur
WORKDIR /app

# On copie et installe les dépendances
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# On copie le code de l'app
COPY app.py .

# On dit que l'app utilise le port 5000
EXPOSE 5000

# La commande pour démarrer l'app
CMD ["python", "app.py"]
