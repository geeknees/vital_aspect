require "test_helper"

class OkrAiServiceTest < ActiveSupport::TestCase
  class FakeOpenAIClient
    attr_reader :received_params

    def chat(parameters:)
      @received_params = parameters
      {
        "choices" => [
          { "message" => { "content" => "- 売上を50%向上\n- 新規顧客を30社獲得" } }
        ]
      }
    end
  end

  test "suggest_key_results returns parsed key results" do
    client = FakeOpenAIClient.new
    service = OkrAiService.new(client: client)

    results = service.suggest_key_results("売上向上")

    assert_equal [ "売上を50%向上", "新規顧客を30社獲得" ], results
    assert_match "売上向上", client.received_params[:messages].first[:content]
  end
end
