# Postgres Dockerfile
FROM postgres:13

# Set environment variables for Postgres
ENV POSTGRES_USER=${DB_USER}
ENV POSTGRES_PASSWORD=${DB_PASSWORD}
ENV POSTGRES_DB=${DB_NAME}

# Expose the PostgreSQL port
EXPOSE 5432

# Default command to start the database
CMD ["postgres"]
