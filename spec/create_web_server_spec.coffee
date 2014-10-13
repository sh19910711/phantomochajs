create_web_server = require "../lib/create_web_server"
request = require "supertest"

describe "create_web_server", ->

  context "create server", ->

    before ->
      @server = create_web_server(
        # scripts
        {}
        # options
        {
          test_dependencies: [
            "url/to/mocha.js"
          ]
        }
      )

    after ->
      @server.close()

    context "GET /test_runner.html", ->

      context "response headers", ->

        it "Status: 200", (done)->
          request(@server)
            .get "/test_runner.html"
            .expect 200, done

        it "Contain mocha.js", (done)->
          request(@server)
            .get "/test_runner.html"
            .expect /mocha\.js/, done
          

    context "GET /test_runner.html?grep=foo", ->

      context "response headers", ->

        it "Status: 200", (done)->
          request(@server)
            .get "/test_runner.html"
            .expect 200, done

        it "Contain mocha.js", (done)->
          request(@server)
            .get "/test_runner.html"
            .expect /mocha\.js/, done

