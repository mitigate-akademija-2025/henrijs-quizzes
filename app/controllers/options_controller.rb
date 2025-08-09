class OptionsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_question, only: %i[new create]
  before_action :set_option, only: %i[edit update destroy]
  before_action :authorize_option!, only: %i[edit update destroy]

  def new
    @option = @question.options.build
  end

  def create
    @option = @question.options.build(option_params)
    if @option.save
      redirect_to @question, notice: "Option added."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @option.update(option_params)
      redirect_to @option.question, notice: "Option updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    question = @option.question
    @option.destroy
    redirect_to question, notice: "Option removed."
  end

  private

  def set_question
    @question = Question.includes(:quiz).find(params[:question_id])
  end

  def set_option
    @option = Option.includes(question: :quiz).find(params[:id])
  end

  def authorize_option!
    redirect_to @option.question, alert: "Not allowed." unless @option.question.quiz.user_id == current_user.id
  end

  def option_params
    params.require(:option).permit(:body, :correct)
  end
end
