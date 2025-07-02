class CasesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_case, only: [:show, :start_reading, :complete_reading, :mark_for_teaching, :mark_for_qa]

  def index
    @cases = current_user.cases.includes(:tasks).order(created_at: :desc)
  end

  def show
    @case = Case.find(params[:id])
    @related_tasks = @case.tasks.order(:created_at)

    # Crear tarea de interpretación automáticamente si no existe
    unless @case.tasks.interpretation.exists?
      @case.tasks.create!(
        title: "Interpretar #{@case.modality} #{@case.body_part}",
        task_type: :interpretation,
        priority: @case.priority,
        user: current_user,
        due_date: calculate_due_date(@case.priority)
      )
    end
  end

  def worklist
    @stat_cases = current_user.cases.stat.where(study_status: :pending).order(:created_at)
    @urgent_cases = current_user.cases.urgent.where(study_status: :pending).order(:created_at)
    @routine_cases = current_user.cases.routine.where(study_status: :pending).order(:created_at)
    @in_progress_cases = current_user.cases.in_progress.order(:updated_at)
  end

  def start_reading
    @case.update!(study_status: :in_progress)

    # Buscar o crear tarea de interpretación
    interpretation_task = @case.tasks.interpretation.first
    if interpretation_task&.pending?
      interpretation_task.start_timer!
    end

    redirect_to @case, notice: 'Caso iniciado. ¡Buena lectura!'
  end

  def complete_reading
    @case.update!(study_status: :reported)

    # Completar tarea de interpretación si existe
    interpretation_task = @case.tasks.interpretation.first
    if interpretation_task&.in_progress?
      interpretation_task.complete!
    end

    redirect_to @case, notice: 'Caso completado. ¡Excelente trabajo!'
  end

  def mark_for_teaching
    task = @case.tasks.first
    notes = params[:teaching_notes] || "Caso interesante para enseñanza"

    task.mark_for_teaching!(notes)
    redirect_to @case, notice: 'Caso marcado para enseñanza'
  end

  def mark_for_qa
    task = @case.tasks.first
    notes = params[:qa_notes] || "Caso para revisión de calidad"

    task.mark_for_qa!(notes)
    redirect_to @case, notice: 'Caso marcado para QA'
  end

  private

  def set_case
    @case = Case.find(params[:id])
  end

  def calculate_due_date(priority)
    case priority
    when 'stat'
      1.hour.from_now
    when 'urgent'
      4.hours.from_now
    when 'routine'
      24.hours.from_now
    end
  end
end
