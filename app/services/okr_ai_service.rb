class OkrAiService
  DEFAULT_MODEL = ENV.fetch("OPENAI_MODEL", "gpt-4o")

  def initialize(client: OpenAI::Client.new(access_token: ENV["OPENAI_API_KEY"]))
    @client = client
  end

  def suggest_key_results(objective)
    prompt = <<~PROMPT
      あなたは熟練のOKRコーチです。以下のObjectiveに対して、日本語で2\~3個のKey Result案をハイフン区切りの箇条書きで提案してください。
      Objective: #{objective}
    PROMPT

    response = @client.chat(
      parameters: {
        model: DEFAULT_MODEL,
        messages: [
          { role: "user", content: prompt }
        ],
        temperature: 0.7
      }
    )

    text = response.dig("choices", 0, "message", "content").to_s
    text.lines.map { |line| line.delete_prefix("-").strip }.reject(&:empty?)
  end
end
