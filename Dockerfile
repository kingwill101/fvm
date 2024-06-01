FROM dart:stable

LABEL org.opencontainers.image.source https://github.com/kingwill101/fvm
LABEL org.opencontainers.image.authors kingwill101 hey@glenfordwilliams.com
LABEL org.opencontainers.image.title fvm
LABEL org.opencontainers.image.description FVM image with dart:stable as base.
LABEL org.opencontainers.image.vendor https://github.com/kingwill101

ARG FVM_VERSION=3.1.4
ARG FLUTTER_VERSION=3.19.3
ARG USER=fvm
ARG USER_UID=1000
ARG USER_GID=$USER_UID
ARG APP_DIR=/home/${USER}/app
ARG FVM_SDK_DIR=/home/${USER}/fvm/versions/${FLUTTER_VERSION}

ENV FVM_SDK_DIR=${FVM_SDK_DIR}
ENV USER=${USER}
ENV APP_DIR=${APP_DIR}

RUN apt-get update --quiet --yes && apt-get install --quiet --yes unzip apt-utils

# Create a non-root user to use if preferred - see https://aka.ms/vscode-remote/containers/non-root-user.
RUN groupadd --gid $USER_GID $USER \
  && useradd -s /bin/bash --uid $USER_UID --gid $USER_GID -m $USER \
  # [Optional] Add sudo support for the non-root user
  && apt-get install -y sudo \
  && echo $USER ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USER\
  && chmod 0440 /etc/sudoers.d/$USER \
  # Clean up
  && apt-get autoremove -y \
  && apt-get clean -y \
  && rm -rf /var/lib/apt/lists/*

USER ${USER}
WORKDIR /home/${USER}
RUN dart pub global activate fvm
ENV PATH="/home/${USER}/.pub-cache/bin:${PATH}"
RUN fvm install ${FLUTTER_VERSION}
RUN fvm global ${FLUTTER_VERSION}
RUN fvm dart pub global activate melos
RUN fvm flutter doctor -v
RUN fvm flutter config --enable-web
RUN fvm flutter precache --web --force
RUN mkdir -p ${APP_DIR}
WORKDIR ${APP_DIR}