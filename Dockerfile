# download platform dependend env files
FROM alpine:latest as builder
ARG dsm_version=7.1
ARG dsm_platform
RUN apk --no-cache add curl
RUN echo "Downloading ${dsm_version} ${dsm_platform}..." \
	&&mkdir -p /tmp/build_env \
	&& curl -L https://global.download.synology.com/download/ToolChain/toolkit/${dsm_version}/${dsm_platform}/ds.${dsm_platform}.${dsm_version}.env.txz | tar xzJ -C /tmp/build_env \
	&& curl -L https://global.download.synology.com/download/ToolChain/toolkit/${dsm_version}/${dsm_platform}/ds.${dsm_platform}.${dsm_version}.dev.txz | tar xzJ -C /tmp/build_env

# create platform dependend build env
FROM awoland/dsmpkg-env:${dsm_version}-base
COPY --from=builder /tmp/build_env /

