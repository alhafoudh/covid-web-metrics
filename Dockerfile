FROM gliderlabs/herokuish

RUN mkdir -p /app
ADD . /app
WORKDIR /app
RUN /build

EXPOSE 9292

ENTRYPOINT ["/exec", "rackup", "app.rb"]
