# Stage 1: Build environment
FROM python:3.8-slim-buster as builder

# Set environment variables for Python
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

# Create and set the working directory in the container
WORKDIR /app

# Copy the requirements file into the container
COPY requirements.txt /app/

# Install project dependencies into a virtual environment
RUN python -m venv /venv
RUN /venv/bin/pip install --no-cache-dir -r requirements.txt

# Stage 2: Runtime environment
FROM python:3.8-slim-buster

# Set environment variables for Python
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

# Create and set the working directory in the container
WORKDIR /app

# Copy the virtual environment from the builder stage
COPY --from=builder /venv /venv

# Copy the entire project directory into the container
COPY . /app/

# Expose the port your Django app will run on
EXPOSE 8000

# Start the Django development server
CMD ["/venv/bin/python", "manage.py", "runserver", "0.0.0.0:8000"]
