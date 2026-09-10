# Callibrate as one container, for a demonstration host.
#
#   docker build -t callibrate .
#   docker run -p 8000:8000 -e CBR_ALLOWED_HOSTS=localhost callibrate
#
# The image ships the pilot caller and nothing else: `CBR_CALLER_MODE` defaults
# to `pilot`, and `CBR_CALL_ALLOWLIST` is empty, so a container that somebody
# starts by accident cannot telephone anybody. Live calling needs a CALL-E token
# and an explicit allowlist, both supplied at run time.

FROM python:3.12-slim

ENV PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1

WORKDIR /app

COPY pyproject.toml README.md ./
COPY src ./src
RUN pip install .

# The directory is seeded into SQLite when the database is empty, which is what
# makes a fresh container a working demonstration rather than a login page.
ENV CBR_DATABASE_PATH=/data/callibrate.db \
    CBR_HOST=0.0.0.0 \
    CBR_PORT=8000 \
    CBR_ENVIRONMENT=development \
    CBR_CALLER_MODE=pilot \
    CBR_BOOTSTRAP_SAMPLE_DATA=true \
    CBR_ALLOWED_HOSTS=localhost,127.0.0.1
RUN mkdir -p /data

EXPOSE 8000
# The host names the port; Render, Fly and Cloud Run all do it through PORT.
CMD ["sh", "-c", "callibrate serve --host 0.0.0.0 --port ${PORT:-8000}"]
