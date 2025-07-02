class QaCasesController < ApplicationController
   before_action :authenticate_user!

  def index
    # Obtener casos únicos marcados para QA
    @qa_cases = Task.qa_cases_for_user(current_user)

    # Agrupar por prioridad
    @cases_by_priority = @qa_cases.group_by(&:priority)

    # Estadísticas
    @total_qa_cases = @qa_cases.count
    @urgent_qa_count = @qa_cases.select(&:urgent?).count
    @stat_qa_count = @qa_cases.select(&:stat?).count
  end

  def show
    @case = Case.find(params[:id])
    @qa_task = @case.tasks.marked_for_qa.first

    # Verificar que el caso pertenece al usuario actual
    unless @case.user == current_user
      redirect_to qa_cases_path, alert: 'No tienes acceso a este caso'
      return
    end

    # Tareas relacionadas del mismo caso
    @all_case_tasks = @case.tasks.order(:created_at)
  end
end
