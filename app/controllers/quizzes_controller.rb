class QuizzesController < ApplicationController
  before_action :authenticate_user!, except: [ :index, :show ]
  before_action :set_quiz, only: [ :show, :edit, :update, :destroy ]

  after_action :verify_authorized, except: [ :index ]
  # after_action :verify_policy_scoped, only: [ :index ]

  def index
    if params[:search].present?
      @quizzes = Quiz.where("title LIKE ?", "%#{params[:search]}%")
                     .includes(:user)
                     .order(created_at: :desc)
    else
      @quizzes = Quiz.includes(:user).order(created_at: :desc)
    end
  end

  def show
    authorize @quiz
    @top_games = @quiz.games.where.not(finished_at: nil)
                     .order(score: :desc, finished_at: :asc)
                     .includes(:user).limit(10)

    @games_count = @quiz.games.where.not(finished_at: nil).count
    @total_questions = @quiz.questions.size

    @total_points = @quiz.questions.sum(:points)
    @total_points = 1 if @total_points.zero?

    @average_score = @quiz.games.where.not(score: nil).average(:score).to_f
    @average_percentage = @total_questions.positive? ? ((@average_score / @total_points) * 100).round : 0

    @feedbacks = @quiz.feedbacks.includes(:user).order(created_at: :desc)
  end

  def new
    @quiz = current_user.quizzes.build
    authorize @quiz
    q = @quiz.questions.build(
      type: "ChoiceQuestion",
      points: 1,
    )
    2.times { q.options.build }
  end

  def create
    @quiz = current_user.quizzes.build(quiz_params)
    authorize @quiz
    if @quiz.save
      redirect_to @quiz, notice: "Quiz created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @quiz
  end

  def update
    authorize @quiz
    if @quiz.update(quiz_params)
      redirect_to @quiz, notice: "Quiz updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @quiz
    @quiz.destroy
    redirect_to quizzes_path, notice: "Quiz deleted."
  end

  def generate_with_gemini
    authorize Quiz

    description = params.require(:description)

    generator = QuizGenerators::GeminiGenerator.new
    data = generator.generate_from_description(description)

    quiz = current_user.quizzes.build(
      title: data[:title],
      description: data[:description]
    )

    data[:questions].each_with_index do |q, idx|
      question = quiz.questions.build(
        type: q[:type],
        content: q[:content],
        points: q[:points] || 1,
        position: idx + 1,
        max_selections: q[:maxSelections],
        image_path: q[:imagePath]
      )

      Array(q[:options]).each do |opt|
        question.options.build(content: opt[:content], correct: !!opt[:correct])
      end
    end

    if quiz.save
      redirect_to edit_quiz_path(quiz), notice: "Quiz generated from Gemini."
    else
      render :new, status: :unprocessable_entity, locals: { quiz: quiz }, notice: "Could not save quiz."
    end
  rescue => e
    Rails.logger.error(e.full_message)
    redirect_to new_quiz_path, alert: "AI generation failed: #{e.message}"
  end

  private
  def set_quiz
    @quiz = Quiz.includes(questions: :options).find(params[:id])
  end

    def quiz_params
    params.fetch(:quiz, {}).permit(
      :title, :description,
      questions_attributes: [
        :id, :type, :content, :points, :_destroy, :remove_image, :image,
        { options_attributes: [ :id, :content, :correct, :_destroy ] }
      ]
    )
  end
end
