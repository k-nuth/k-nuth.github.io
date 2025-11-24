FROM --platform=linux/amd64 python:3.11-bookworm

# Build argument for Knuth version
ARG KTH_VERSION=0.73.0
ENV KTH_VERSION=${KTH_VERSION}

WORKDIR /workspace

COPY test-docker.sh /workspace/

RUN chmod +x /workspace/test-docker.sh

# Run the test script
CMD ["/workspace/test-docker.sh"]
