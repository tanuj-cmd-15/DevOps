FROM python:3.9-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY app.py .

EXPOSE 5000

CMD ["python", "app.py"]
```

### 1.2 Update `backend/requirements.txt`
```
Flask==3.0.0
flask-cors==4.0.0