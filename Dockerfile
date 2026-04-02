FROM apache/superset:latest

USER root
RUN apt-get update && apt-get install -y python3-pip && \
    pip install pymssql && \
    cp -r /usr/local/lib/python3.10/site-packages/pymssql /app/.venv/lib/python3.10/site-packages/ && \
    cp -r /usr/local/lib/python3.10/site-packages/pymssql.libs /app/.venv/lib/python3.10/site-packages/ && \
    cp -r /usr/local/lib/python3.10/site-packages/pymssql-2.3.13.dist-info /app/.venv/lib/python3.10/site-packages/
USER superset
