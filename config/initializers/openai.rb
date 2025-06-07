require "openai"

OpenAIClient = OpenAI::Client.new(access_token: ENV["OPENAI_API_KEY"]) if ENV["OPENAI_API_KEY"]
