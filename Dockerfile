FROM node:18-alpine

# Set working directory
WORKDIR /app

# Copy only package files first (better caching)
COPY package*.json ./

# Install production dependencies
RUN npm ci --omit=dev

# Copy rest of the backend source code
COPY . .

# Expose backend port
EXPOSE 5000

# Set NODE_ENV explicitly
ENV NODE_ENV=production

# Start backend
CMD ["node", "backend/server.js"]
