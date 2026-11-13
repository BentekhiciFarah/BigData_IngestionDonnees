FROM node:22-alpine@sha256:b6f26b36c8ff49624cfdac716b8ea1138d606df02586a77d364bb5536a634f85
WORKDIR /app
RUN npm install --global json-server@0.17.4
COPY db.json /app/initial-db.json
COPY start.sh /app/start.sh
EXPOSE 3000
ENTRYPOINT ["sh", "/app/start.sh"]
