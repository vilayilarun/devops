# Use an official Python runtime as the base image
FROM python:3.9-slim-buster as build

# Set the working directory
WORKDIR /app

# Copy the requirements file
COPY requirements.txt .

# Install the dependencies
RUN pip install --no-cache-dir -r requirements.txt

COPY helloworld.py /app/
# Expose the port
EXPOSE 5000

# Run the application
CMD ["python", "helloworld.py"]

# Build the final image
FROM python:3.9-slim-buster 
COPY --from=build /app /app
EXPOSE 5000
CMD ["python", "/app/helloworld.py"]
