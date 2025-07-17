FROM node:24

# Set working directory
WORKDIR /app

# Copy package.json and package-lock.json to the working directory
COPY package*.json ./

# Install project dependencies
RUN npm install

# Copy the remaining application source code into the container
COPY . .

# Build the production version of the frontend (e.g., Next.js app)
RUN npm run build

# Expose port 3000 to allow external access to the app (default for many frontend frameworks)
EXPOSE 3000

# Start the frontend server
CMD ["npm", "run", "start"]
