class QuizzesController < ApplicationController
  before_action :authenticate_user!, except: [ :index, :show ]
  before_action :set_quiz, only: [ :show, :edit, :update, :destroy ]
  before_action :authorize_quiz!, only: [ :edit, :update, :destroy ]

  def index
    @quizzes = Quiz.includes(:user).order(created_at: :desc)
  end

  def show
    @top_games = @quiz.games
      .where.not(finished_at: nil)
      .order(score: :desc, finished_at: :asc)
      .includes(:user)
      .limit(10)

    @games_count = @quiz.games.where.not(finished_at: nil).count
    @total_questions = @quiz.questions.size
    @average_score = @quiz.games.where.not(score: nil).average(:score).to_f
    @average_percentage = @total_questions.positive? ? ((@average_score / @total_questions) * 100).round : 0
  end


  def new
    @quiz = current_user.quizzes.build
    # start with 1 question, 2 options
    q = @quiz.questions.build
    2.times { q.options.build }
  end

  def create
    @quiz = current_user.quizzes.build
    @quiz.assign_attributes(quiz_params) if params[:quiz].present?

    if params.key?(:add_question)
      new_q = @quiz.questions.build
      new_q.options.build
      render :new

    elsif params.key?(:add_option_for)
      idx = params[:add_option_for].to_i
      if (question = @quiz.questions[idx])
        question.options.build
      end
      render :new

    elsif @quiz.save
      redirect_to @quiz, notice: "Quiz created."

    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    @quiz.assign_attributes(quiz_params) if params[:quiz].present?

    if params.key?(:add_question)
      new_q = @quiz.questions.build
      new_q.options.build
      render :edit

    elsif params.key?(:add_option_for)
      idx = params[:add_option_for].to_i
      if (question = @quiz.questions[idx])
        question.options.build
      end
      render :edit

    elsif @quiz.save
      redirect_to @quiz, notice: "Quiz updated."

    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @quiz.destroy
    redirect_to quizzes_path, notice: "Quiz deleted."
  end

  private

  def set_quiz
    @quiz = Quiz.includes(questions: :options).find(params[:id])
  end

  def authorize_quiz!
    redirect_to @quiz, alert: "Not allowed." unless @quiz.user_id == current_user.id
  end

  def quiz_params
    params.fetch(:quiz, {}).permit(
      :title, :description,
      questions_attributes: [
        :id, :content, :_destroy,
        { options_attributes: [ :id, :content, :correct, :_destroy ] }
      ]
    )
  end
end
