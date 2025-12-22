FROM atcr.io/neutrino2211.bsky.social/qrk-inflect:latest

ARG MODEL_CONFIG_URL
ENV MODEL_CONFIG_URL=$MODEL_CONFIG_URL
ADD preload_model.sh /preload_model.sh
RUN apt-get update && apt-get install bash
RUN chmod +x /preload_model.sh && /preload_model.sh

# Copy the model to the volume
FROM atcr.io/neutrino2211.bsky.social/qrk-inflect:latest
COPY --from=0 /runpod-volume /runpod-volume
