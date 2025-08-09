class QuestionsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_quiz, only: %i[new create]
  before_action :set_question, only: %i[show edit update destroy]
  before_action :authorize_question!, only: %i[edit update destroy]

  def show
    # shallow route: /questions/:id
  end

  def new
    @question = @quiz.questions.build
  end

  def create
    @question = @quiz.questions.build(question_params)
    if @question.save
      redirect_to @question, notice: "Question added."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @question.update(question_params)
      redirect_to @question, notice: "Question updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    quiz = @question.quiz
    @question.destroy
    redirect_to quiz_path(quiz), notice: "Question removed."
  end

  private

  def set_quiz
    @quiz = Quiz.find(params[:quiz_id])
  end

  def set_question
    @question = Question.includes(:quiz).find(params[:id])
  end

  def authorize_question!
    redirect_to @question, alert: "Not allowed." unless @question.quiz.user_id == current_user.id
  end

  def question_params
    params.require(:question).permit(:body)
  end
end
