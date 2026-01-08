FROM node:18-alpine

WORKDIR /app

COPY package*.json ./

# Install only production dependencies
RUN npm ci --omit=dev

COPY . .

EXPOSE 5000

CMD ["npm", "start"]
