require "csv"

class GamesController < ApplicationController
  before_action :set_quiz, only: [ :new, :create, :export ]
  before_action :set_game, only: [ :show ]

  def new
    session["game_started_at_#{@quiz.id}"] = Time.current.to_i
    @game = @quiz.games.build
  end

  # submit game
  def create
    ts = session.delete("game_started_at_#{quiz_id}")
    ts ? Time.zone.at(ts.to_i) : Time.current

    permitted = params.permit(answers: {}, text_answers: {})
    choice_params = permitted[:answers] || {}
    text_params = permitted[:text_answers] || {}

    @game = GameSubmission.new(
      quiz: @quiz,
      user: (current_user if user_signed_in?),
      started_at: started_at,
      choice_params: choice_params,
      text_params: text_params
    ).call

    redirect_to game_path(@game), notice: "Quiz finished!"

  rescue ActiveRecord::RecordInvalid => e
    flash.now[:alert] = "Failed to save answers."
    render :new, status: :unprocessable_entity
  end

  # show results
  def show
    @quiz = @game.quiz
    @results = GameResults.new(@game).call
    @feedbacks = @quiz.feedbacks.where(user: current_user).order(created_at: :desc)
  end

  def export
    games = @quiz.games.where.not(finished_at: nil).includes(:user).order(:finished_at)

    csv = CSV.generate(headers: true) do |c|
      c << [ "Game ID", "Player", "Score", "Duration (seconds)", "Finished (timestamp)" ]
      games.find_each do |g|
        c << [
          g.share_token,
          (g.user&.username.presence || "Guest"),
          g.score,
          (g.finished_at - g.started_at).to_i,
          g.finished_at&.iso8601
        ]
      end
    end

    filename = "quiz-#{@quiz.id}-results-#{Time.zone.now.strftime('%Y%m%d-%H%M')}.csv"
    send_data csv, filename:, type: "text/csv"
  end

  private

  def set_quiz
    @quiz = Quiz.includes(questions: :options).find(params[:quiz_id])
  end

  def set_game
    @game = Game.includes(:quiz, guesses: :option).find_by!(share_token: params[:id])
  end
end
