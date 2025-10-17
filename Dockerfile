FROM julia:1.10

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy project files
COPY Project.toml Manifest.toml ./
COPY files/ ./files/
COPY start-api.jl ./

# Precompile dependencies
RUN julia --project=. -e 'using Pkg; Pkg.instantiate(); Pkg.precompile()'

# Expose port (Render uses PORT env var)
ENV PORT=10000
EXPOSE 10000

# Start the API server
CMD julia --project=. start-api.jl
