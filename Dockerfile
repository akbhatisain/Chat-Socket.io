# Stage 1: Builder Stage (Install dependencies)
FROM node:18 AS builder

# Set the working directory
WORKDIR /app

# Copy package.json and package-lock.json first to leverage Docker cache
COPY package*.json ./

# Install only production dependencies
RUN npm ci --only=production

# Copy the entire application source code
COPY . .

# Expose the application port
EXPOSE 3000

# Set the default command
CMD ["node", "index.js"]
