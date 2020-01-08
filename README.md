# mandelbulber2-google-cloud

## Getting Started

1. Install Google Cloud SDK
   [https://cloud.google.com/sdk/docs/quickstart-macos](https://cloud.google.com/sdk/docs/quickstart-macos)

2. Setup and Authenticate Google Cloud CLI

```
gcloud init
```

3. Create a bucket called `mandelbulber`, and add the contents of the `bucket` folder in there

so:

```
bucket: mandelbulber
  |- mandelbulber exec
  |- render.sh
  |- input
    |- yourfractal.fract
```

3. Run the Script with a unique project name (will be used to ID your instance, nothing else)

```
chmod +x init.sh
./init.sh myUniqueId

```

the script will run and resume automatically