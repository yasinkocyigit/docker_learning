# First stage (build stage)
# AS build: Assigns the name "build" to this stage.
FROM alpine:3.5 AS build

# Updates the package index and installs the C compiler and build tools.
RUN apk update && \
    apk add --update alpine-sdk

# Creates the application directory.
RUN mkdir /app

# Sets the working directory to /app.
WORKDIR /app

# Copies the source code into the container.
COPY helloworld.c /app

# Creates the directory where the compiled binary will be stored.
RUN mkdir bin

# Compiles the C program and generates the executable at /app/bin/helloworld.
RUN gcc -Wall helloworld.c -o bin/helloworld

# ------------------------------------------------------

# Second stage (runtime stage)
# Starts with a clean Alpine image.
FROM alpine:3.5

# Copies the compiled executable from the build stage into the runtime image.
COPY --from=build /app/bin/helloworld /app/helloworld

# Specifies the command to run when the container starts.
CMD ["/app/helloworld"]