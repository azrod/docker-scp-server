# docker-scp-server

This is a mainly unmodified fork of [schoolscout/scp-server](https://github.com/schoolscout/scp-server) with the following changes:

- Update alpine base image to 3.20
- Add GithubAction to build and push the image to ghcr.io

Restricted SSH server which allows SCP / SFTP access only.

## Running

1) Put your authorized keys in an ENV variable and run the image:

Use the `AUTHORIZED_KEYS_BASE64` or `AUTHORIZED_KEYS` environment variable to specify the authorized keys for the `data` user. The value should be a base64-encoded string of the `authorized_keys` file.

    ```bash
    AUTHORIZED_KEYS_BASE64=$(base64 -w0 my-authorized-keys)

    docker run -d \
      -e AUTHORIZED_KEYS_BASE64=$AUTHORIZED_KEYS_BASE64 \
      -p <PORT>:22 \
      -v <DATADIR>:/home/data \
      -v <HOSTKEYDIR>:/var/local/etc/ssh \
      ghcr.io/azrod/docker-scp-server
    ```

    Alternatively, mount your `authorized_keys` file into the container at `/run/secrets/authorized_keys`:

    ```bash
    docker run -d \
      -v /path/to/my/authorized_keys:/run/secrets/authorized_keys \
      -p <PORT>:22 \
      -v <DATADIR>:/home/data \
      -v <HOSTKEYDIR>:/var/local/etc/ssh \
      ghcr.io/azrod/docker-scp-server
    ```

2) Now you can copy into the container (e.g. via scp) as the `data` user:

    ```bash
    scp -P <PORT> <FILE> data@<DOCKER-HOST>:
    ```
