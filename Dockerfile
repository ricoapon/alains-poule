# Inspiration from https://stackoverflow.com/questions/61108021/gradle-and-docker-how-to-run-a-gradle-build-within-docker-container.
# Using multistage docker build (see https://docs.docker.com/develop/develop-images/multistage-build/).

# Temporary container with Gradle to build the project.
FROM gradle:6.9.0-jdk AS TEMP_BUILD_IMAGE
ENV APP_HOME=/usr/app/
WORKDIR $APP_HOME
# Don't merge these copy commands, since Digital Ocean build will complain about this.
COPY settings.gradle $APP_HOME
COPY build.gradle $APP_HOME

COPY gradle $APP_HOME/gradle
COPY --chown=gradle:gradle . /home/gradle/src
USER root
RUN chown -R gradle /home/gradle/src

# Build the actual project.
COPY . .
RUN gradle clean build



# Final container with the jar.
FROM adoptopenjdk/openjdk11:alpine-jre
ENV APP_HOME=/usr/app/

WORKDIR $APP_HOME
COPY --from=TEMP_BUILD_IMAGE $APP_HOME/build/libs/*.jar app.jar

EXPOSE 8080
ENTRYPOINT exec java -jar app.jar
