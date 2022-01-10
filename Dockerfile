# starting to build python dependencies
FROM python:3.11.0a3-slim-bullseye AS build
WORKDIR /wheels
COPY ./flask-app/requirements.txt /wheels/requirements.txt
RUN pip3 wheel -r requirements.txt

# app build from python dependencies
FROM alpine:3.15.0
COPY --from=build /wheels /wheels
RUN apk add python3 py3-pip && \
	pip install --upgrade pip && \
	pip3 install --no-cache-dir \
                       -r /wheels/requirements.txt \
                       -f /wheels/ && \
        		rm -rf /wheels/
WORKDIR /opt/flask-app
ADD flask-app /opt/flask-app
RUN addgroup -S node && adduser -S node -G node
RUN apk add npm &&  npm install --only=production
USER node
EXPOSE 5000


# start app
CMD [ "python3", "./app.py" ]
