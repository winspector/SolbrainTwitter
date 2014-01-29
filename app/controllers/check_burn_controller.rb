# -*- coding:utf-8 -*-
class CheckBurnController < ApplicationController
  # ダッシュボード的役割を果たします
  def index
    @all_tweet_count = Tweet.count
  end

  # 判定用のTweetを1p分取得します
  def question_tweets
    @tweets = Tweet.where('checked = ?', false).limit(20)

    respond_to do |format|
      format.html do
        puts 'htmlできてる'
        return
      end
      format.js do
        @append_html = render_to_string(partial: 'tweets', collection: @tweets)
        puts @append_html
        puts 'jsできてる'
        return
      end
    end
  end

  # 判定します
  def judge
    puts 'judgeにきています'

    tweet = Tweet.find(params[:check][:id].to_i)
    tweet.update_attributes(checked:true, may_burn:params[:check][:answer])
    tweet.save!

    @tweet_id = tweet.id

    respond_to do |format|
      format.html do
        puts 'htmlできてる'
        redirect_to check_burn_question_tweets_path
        return
      end
      format.js do
        puts 'jsできてる'
        return
      end
    end
  end
end
