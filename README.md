# mandelbulber2-google-cloud

## Getting Started

1. Install Google Cloud SDK
   [https://cloud.google.com/sdk/docs/quickstart-macos](https://cloud.google.com/sdk/docs/quickstart-macos)

2. Setup and Authenticate Google Cloud CLI

```
gcloud init
```

3. Create a bucket called `mandelbulber` and add mandelbulber2 linux binary in there, as well as a `input` directory, which contains your `*.fract` file

so:

```
bucket: mandelbulber
  |- mandelbulber exec
  |- input
    |- something.fract
```

3. Run Script!

```
chmod +x init.sh
./init.sh

```
