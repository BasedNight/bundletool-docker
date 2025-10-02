# ---------- stage 1: fetch the JAR ----------
FROM debian:bookworm-slim AS fetch
ARG BUNDLETOOL_VERSION=1.18.2
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends curl ca-certificates; \
    curl -fsSL -o /bundletool.jar \
      "https://github.com/google/bundletool/releases/download/${BUNDLETOOL_VERSION}/bundletool-all-${BUNDLETOOL_VERSION}.jar"; \
    apt-get purge -y curl; \
    rm -rf /var/lib/apt/lists/*

# Optional integrity pin (pass at build time):
# ARG BUNDLETOOL_SHA256
# RUN [ -z "$BUNDLETOOL_SHA256" ] || echo "$BUNDLETOOL_SHA256  /bundletool.jar" | sha256sum -c -

# ---------- stage 2: runtime ----------
FROM debian:bookworm-slim
# Bookworm's default JRE = OpenJDK 17 headless
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends default-jre-headless ca-certificates; \
    rm -rf /var/lib/apt/lists/*

# Non-root user
RUN useradd --system --uid 10001 --create-home --shell /usr/sbin/nologin app
WORKDIR /work

# JAR + tiny wrapper
COPY --from=fetch /bundletool.jar /opt/bundletool/bundletool.jar
RUN printf '#!/bin/sh\nexec java -jar /opt/bundletool/bundletool.jar "$@"\n' > /usr/local/bin/bundletool \
 && chmod +x /usr/local/bin/bundletool \
 && chown -R app:app /opt/bundletool
USER app

ENTRYPOINT ["bundletool"]
CMD ["help"]
