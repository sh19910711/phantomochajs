create_web_server = require "../lib/create_web_server"
request = require "supertest"

describe "create_web_server", ->

  context "enable amd_glob", ->

    before ->
      @server = create_web_server(
        # scripts
        {
          "/modules/a.js"
          "/modules/b.js"
          "/modules/c.js"
          "/modules2/1.js"
          "/modules2/2.js"
          "/modules2/3.js"
        }
        # options
        {
          debug: true
          host: "127.0.0.1"
          port: 19292
          amd_glob: true
        }
      )

    after ->
      @server.close()

    context "GET /modules/*", ->
    
      beforeEach ->
        @res = request(@server)
          .get "/spec/*.js"

      context "response headers", ->

        it "Status: 200", (done)->
          @res.expect 200, done

        it "contains create_web_server_spec", (done)->
          @res.expect /create_web_server_spec/, done

        it "does not contain modules", (done)->
          @res
            .expect (res)->
              return true if /modules/.test(res.text)
              return false
            .end done

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

      beforeEach ->
        @res = request(@server)
          .get "/test_runner.html"

      context "response headers", ->

        it "Status: 200", (done)->
          @res.expect 200, done

        it "Contain mocha.js", (done)->
          @res.expect /mocha\.js/, done

    context "GET /test_runner.html2", ->
      
      beforeEach ->
        @res = request(@server)
          .get "/test_runner2.html"

      context "response headers", ->
        it "Status: 404", (done)->
          @res.expect 404, done

    context "GET /test_runner.html?grep=foo", ->

      beforeEach ->
        @res = request(@server)
          .get "/test_runner.html?grep=foo"

      context "response headers", ->

        it "Status: 200", (done)->
          @res.expect 200, done

        it "Contain mocha.js", (done)->
          @res.expect /mocha\.js/, done

