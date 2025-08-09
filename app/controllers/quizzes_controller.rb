class QuizzesController < ApplicationController
  before_action :authenticate_user!, except: %i[index show]
  before_action :set_quiz, only: %i[show edit update destroy]
  before_action :authorize_quiz!, only: %i[edit update destroy]

  def index
    @quizzes = Quiz.includes(:user).order(created_at: :desc)
  end

  def show
  end

  def new
    @quiz = current_user.quizzes.build
  end

  def create
    @quiz = current_user.quizzes.build(quiz_params)
    if @quiz.save
      redirect_to @quiz, notice: "Quiz created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @quiz.update(quiz_params)
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
    @quiz = Quiz.find(params[:id])
  end

  def authorize_quiz!
    redirect_to @quiz, alert: "Not allowed." unless @quiz.user_id == current_user.id
  end

  def quiz_params
    params.require(:quiz).permit(:title, :description)
  end
end
