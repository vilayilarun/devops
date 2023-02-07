# Use an official Python runtime as the base image
FROM python:3.9-slim-buster 

# Set the working directory
WORKDIR /app

# Copy the requirements file
COPY requirements.txt .

# Install the dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy the application code
COPY helloworld.py /app/

# Expose the port
EXPOSE 5000

# Run the application
CMD ["python", "helloworld.py"]

# Build the final image
FROM python:3.9-slim-buster AS release
COPY --from=python:3.9-slim-buster /app /app
EXPOSE 5000
CMD ["python", "helloworld.py"]
