Bundletool Dockerfile + APK Helper Makefile
=================================
I created this Dockerfile because I use NixOS, and I could not get the package from Nixpkgs to work for the life of me—presumably because glibc and Nix would not play nice. My use case is to produce signed APKs from an Android app bundle, so I also threw together a quick Makefile to help me do so using the containerized `bundletool`.

Building & testing
----------------
1. Clone this repository: `git clone https://github.com/BasedNight/bundletool-docker.git`
2. Build the Docker image with your preferred version: `docker build -t bundletool:{version} --build-arg BUNDLETOOL_VERSION={version} .`
3. Test the resulting image: `docker run --rm bundletool:{version} version`. The expected output is the version string specified when building the image: for example, `1.18.2`.

Running `bundletool` using the image
----------------
This example assumes you are using the latest version of `bundletool` (at time of writing, 1.18.2), and that you are running this command from the directory containing the input `.aab` file—in this case, `app-release.aab`.

```
docker run --rm -v "$PWD":/work -w /work bundletool:1.18.2 \
  build-apks --bundle=app-release.aab --output=app-release.apks --mode=universal
```

As seen above, `bundletool` itself is implied and need not be included.

Using the APK helper Makefile
----------------
Also included in this repo is a Makefile to quickly produce a signed APK from the Android App Bundle. It depends on `make` and `unzip` being installed on the host system. To use it, two additional files are required (alongside the input `.aab` file):

1. `keystore.bak.jks`, an Android upload keystore.
2. `.env` defining the following environment variables: `KEYSTORE_PASS`, `KEYSTORE_KEY_ALIAS`, and `KEY_PASS`.

With these requirements met, simply use `make {filename}.apk && make clean`, where {filename} is your input bundle minus the `.aab` extension.
