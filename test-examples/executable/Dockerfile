FROM --platform=linux/amd64 python:3.11-bookworm

WORKDIR /workspace

COPY test-docker.sh /workspace/
COPY ../config.json /workspace/

RUN chmod +x /workspace/test-docker.sh

# Run the test script
CMD ["/workspace/test-docker.sh"]
