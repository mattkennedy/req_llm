defmodule ReqLLM.Providers.GoogleFinchTest do
  use ExUnit.Case, async: true

  alias ReqLLM.Providers.Google

  describe "attach/3 Finch pool routing" do
    test "routes the request to the configured Finch pool" do
      request = Google.attach(Req.new(), "google:gemini-2.5-flash", api_key: "test")

      assert request.options[:finch][:name] == ReqLLM.Application.finch_name()
    end

    test "keeps a Finch pool already set on the request" do
      request =
        Req.new()
        |> Req.Request.merge_options(finch: MyApp.CustomFinch)
        |> Google.attach("google:gemini-2.5-flash", api_key: "test")

      assert request.options[:finch][:name] == MyApp.CustomFinch
    end

    # Req 0.7 carries the pool name and the Finch request options in the SAME
    # `:finch` key, so adding the pool name must not discard settings a provider
    # already put there (and vice versa). Both losses are silent: the request
    # still succeeds, but on the wrong pool or with the wrong checkout timeout.
    test "adds the pool name without dropping Finch options already on the request" do
      request =
        Req.new(finch: [pool_timeout: 12_345])
        |> Google.attach("google:gemini-2.5-flash", api_key: "test")

      assert request.options[:finch][:name] == ReqLLM.Application.finch_name()
      assert request.options[:finch][:pool_timeout] == 12_345
    end
  end
end
