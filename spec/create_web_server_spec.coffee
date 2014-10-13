create_web_server = require "../lib/create_web_server"
request = require "supertest"

describe "create_web_server", ->

  context "create server", ->

    before ->
      @server = create_web_server(
        # scripts
        {}
        # options
        {}
      )

    after ->
      @server.close()

    context "GET /test_runner.html", ->

      context "response headers", ->

        it "Content-Type: text/html", ->
          request(@server)
            .get "/test_runner.html"
            .expect 'Content-Type', "text/html"

        it "Status: 200", ->
          request(@server)
            .get "/test_runner.html"
            .expect 200

    context "GET /test_runner.html?grep=foo", ->

      context "response headers", ->

        it "Content-Type: text/html", ->
          request(@server)
            .get "/test_runner.html"
            .expect 'Content-Type', "text/html"

        it "Status: 200", ->
          request(@server)
            .get "/test_runner.html"
            .expect 200

