require 'sinatra'
require 'httparty'
require 'json'

post '/gateway' do
  return if params[:token] != ENV['SLACK_TOKEN']

  message = params[:text].gsub(params[:trigger_word], '').strip

  action, repo = message.split('_').map {|c| c.strip.downcase }
  repo_url = "https://api.github.com/repos/#{repo}"

  case action
    when 'issues'
      resp = HTTParty.get(repo_url)
      resp = JSON.parse resp.body
      respond_message "There are #{resp['open_issues_count']} open issues on #{repo}"
    when 'ashley'
      respond_message "Ashley, you are soooooo good lookin'"
    when 'owner'
      resp = HTTParty.get(repo_url)
      resp = JSON.parse resp.body
      respond_message "#{resp['owner']['login']} owns #{repo}"
  end
end

def respond_message message
  content_type :json
  {:text => message}.to_json
end

get '/anonymize' do
  respond_message params[:text]
  # , params[:channel_id]
  # status 200
end
 
# def postback message, channel
#     slack_webhook = ENV['SLACK_WEBHOOK_URL']
#     HTTParty.post slack_webhook, body: {"text" => message.to_s, "username" => "John Doe", "channel" => params[:channel_id]}.to_json, headers: {'content-type' => 'application/json'}
# end