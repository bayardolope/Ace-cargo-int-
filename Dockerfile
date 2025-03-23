# Usa Python 3.10 slim como base
FROM python:3.10-slim

# Instala dependencias del sistema
RUN apt-get update && apt-get install -y \
    wget \
    gnupg \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# Agrega la clave pública y el repositorio de Chrome
RUN wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | apt-key add - \
    && echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list

# Instala Chrome
RUN apt-get update && apt-get install -y google-chrome-stable \
    && rm -rf /var/lib/apt/lists/*

# Instala ChromeDriver (ajusta la versión según Chrome)
RUN wget -O /tmp/chromedriver.zip https://chromedriver.storage.googleapis.com/114.0.5735.90/chromedriver_linux64.zip \
    && unzip /tmp/chromedriver.zip -d /usr/local/bin/ \
    && rm /tmp/chromedriver.zip \
    && chmod +x /usr/local/bin/chromedriver

# Crea un directorio de trabajo y copia el código
WORKDIR /app
COPY . /app

# Instala las dependencias de Python
# IMPORTANTE: Asegúrate de que 'gunicorn' esté en tu requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

# Expone el puerto (8000 por convención; Railway suele asignar uno dinámico)
EXPOSE 8000

# Comando de arranque con Gunicorn y un timeout de 120s
# Gunicorn tomará la variable $PORT (que define la plataforma) si existe;
# si no, usará 8000 por defecto. Ajusta el timeout según tus necesidades.
ENV PORT 8000
CMD exec gunicorn app:app \
    --bind 0.0.0.0:$PORT \
    --timeout 120
