ARG version=2021.3
FROM docker.io/openvino/ubuntu18_dev:${version} AS builder
USER 0:0
WORKDIR /opt/intel/openvino/deployment_tools/tools/model_downloader
RUN source /opt/intel/openvino/bin/setupvars.sh && \
python3 downloader.py --name vehicle-license-plate-detection-barrier-0106 --num_attempts 5 -j 8 && \
python3 downloader.py --name vehicle-attributes-recognition-barrier-0042 --num_attempts 5 -j 8 && \
python3 downloader.py --name license-plate-recognition-barrier-0001 --num_attempts 5 -j 8
WORKDIR /opt/intel/openvino/deployment_tools/inference_engine/demos
RUN apt-get update && apt-get install -y build-essential && ./build_demos.sh

ARG version
FROM docker.io/openvino/ubuntu20_data_runtime:${version}
WORKDIR /workspace
COPY --from=builder /root/omz_demos_build /workspace/omz_demos_build
COPY --from=builder /opt/intel/openvino/deployment_tools/tools/model_downloader/intel /workspace/models
COPY src src
