require "csv"
class GamesController < ApplicationController
  before_action :set_quiz, only: [ :new, :create, :export ]
  before_action :set_game, only: [ :show ]

  def new
    @game = @quiz.games.build
  end

  # submit game
  def create
    @game = @quiz.games.create!(user: (current_user if user_signed_in?))

    # store guesses
    params[:answers].each_value do |option_ids|
      Array(option_ids).each do |opt_id|
        @game.guesses.create!(option_id: opt_id)
      end
    end

    # calculate score
    @game.update!(
      score: @game.calculate_score,
      finished_at: Time.current,
    )

    redirect_to game_path(@game), notice: "Pārbaude pabeigta."
  end

  # show results
  def show
    @quiz = @game.quiz
    @results = @quiz.questions.map do |q|
      {
        question:    q,
        options:     q.options,
        correct_ids: q.options.where(correct: true).ids,
        chosen_ids:  @game.guesses.where(option_id: q.options.ids).pluck(:option_id)
      }
    end
    @feedbacks = @quiz.feedbacks.where(user: current_user).order(created_at: :desc)
  end

  def export
    games = @quiz.games.where.not(finished_at: nil).includes(:user)

    csv = CSV.generate(headers: true) do |c|
      c << [ "Game ID", "Player", "Score", "Duration (seconds)", "Finished (timestamp)" ]
      games.find_each do |g|
        duration = g.finished_at && g.created_at ? (g.finished_at - g.created_at).to_i : nil
        c << [
          g.id,
          (g.user&.username.presence || "Guest"),
          g.score,
          duration,
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
    # no eager load
    @game = Game.find_by!(share_token: params[:id])
  end
end
