FROM python:latest

ADD . /app
WORKDIR /app

ENV API_TOKEN="tok_live_catalogo_9f3ac21b"

RUN pip install -r requirements.txt

CMD ["python", "app.py"]
