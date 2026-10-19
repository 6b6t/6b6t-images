FROM alpine:3.24@sha256:294b683cb724975bec92580e1e685676bd4b50bda910ddb8c51d4cabeaec77e6 AS build

ARG UNFS3_VERSION=0.11.0
ARG UNFS3_SHA256=42ef63cd949b65a4ead30bee269703059a8c4269bef6aa1533215ad1c2a26d6f

RUN apk add --no-cache build-base flex bison libtirpc-dev pkgconf curl
WORKDIR /src
COPY filehandle-cache.patch /tmp/filehandle-cache.patch
RUN curl --fail --show-error --location --output unfs3.tar.gz \
      "https://github.com/unfs3/unfs3/releases/download/unfs3-${UNFS3_VERSION}/unfs3-${UNFS3_VERSION}.tar.gz" \
    && echo "${UNFS3_SHA256}  unfs3.tar.gz" | sha256sum -c - \
    && tar -xzf unfs3.tar.gz --strip-components=1 \
    && patch --batch --forward --fuzz=0 --strip=1 --input=/tmp/filehandle-cache.patch \
    && ./configure --prefix=/usr \
    && make -j"$(getconf _NPROCESSORS_ONLN)" \
    && strip unfsd

FROM alpine:3.24@sha256:294b683cb724975bec92580e1e685676bd4b50bda910ddb8c51d4cabeaec77e6

LABEL org.opencontainers.image.source="https://github.com/6b6t/6b6t-images" \
      org.opencontainers.image.description="Userspace NFSv3 server for 6b6t file exports" \
      org.opencontainers.image.version="0.11.0" \
      org.opencontainers.image.licenses="BSD-3-Clause"

RUN apk add --no-cache libtirpc && mkdir -p /export
COPY --from=build /src/unfsd /usr/sbin/unfsd
COPY --from=build /src/LICENSE /usr/share/licenses/unfs3/LICENSE
COPY exports /etc/exports
RUN /usr/sbin/unfsd -T

EXPOSE 2049/tcp
USER 0:0
ENTRYPOINT ["/usr/sbin/unfsd"]
CMD ["-d", "-t", "-p", "-n", "2049", "-m", "2049", "-e", "/etc/exports"]
