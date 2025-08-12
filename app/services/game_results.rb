# frozen_string_literal: true

class GameResults
  def initialize(game)
    @game = game
  end

  def call
    quiz = @game.quiz
    questions = quiz.questions.includes(:options)
    guesses   = @game.guesses.includes(:option)

    # group guesses by question_id
    guesses_by_qid = {}
    guesses.each do |g|
      qid = g.question_id
      guesses_by_qid[qid] ||= []
      guesses_by_qid[qid] << g
    end

    results = []

    questions.each do |q|
      if q.is_a?(ChoiceQuestion)
        correct_ids = collect_correct_option_ids(q)
        chosen_ids  = collect_chosen_option_ids(guesses_by_qid[q.id])
        results << result_for_mcq(q, correct_ids, chosen_ids)
      else
        text_guess, submitted_text = find_text_guess(guesses_by_qid[q.id])
        acceptable = collect_acceptable_texts(q)
        results << result_for_text(q, submitted_text, acceptable)
      end
    end

    results
  end

  private

  def collect_correct_option_ids(question)
    ids = []
    question.options.each do |opt|
      ids << opt.id if opt.correct
    end
    ids.sort
  end

  def collect_chosen_option_ids(guesses_for_question)
    ids = []
    Array(guesses_for_question).each do |g|
      if g.is_a?(ChoiceGuess) && g.option_id
        ids << g.option_id
      end
    end
    ids.sort
  end

  def find_text_guess(guesses_for_question)
    guess = nil
    Array(guesses_for_question).each do |g|
      if g.is_a?(TextGuess)
        guess = g
        break
      end
    end
    submitted = guess ? guess.answer_text.to_s : ""
    [ guess, submitted ]
  end

  def collect_acceptable_texts(question)
    list = []
    question.options.each do |opt|
      if opt.correct
        list << opt.content.to_s
      end
    end
    list
  end

  def normalize(s)
    s.to_s.strip.downcase
  end

  def result_for_mcq(q, correct_ids, chosen_ids)
    {
      type:        :mcq,
      question:    q,
      options:     q.options,
      correct_ids: correct_ids,
      chosen_ids:  chosen_ids,
      correct:     (chosen_ids == correct_ids),
      points:      q.points
    }
  end

  def result_for_text(q, submitted_text, acceptable_answers)
    submitted_norm   = normalize(submitted_text)
    acceptable_norms = acceptable_answers.map { |s| normalize(s) }
    {
      type:               :text,
      question:           q,
      submitted_text:     submitted_text,
      acceptable_answers: acceptable_answers,
      correct:            acceptable_norms.include?(submitted_norm),
      points:             q.points
    }
  end
end
