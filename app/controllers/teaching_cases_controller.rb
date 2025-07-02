class TeachingCasesController < ApplicationController
  before_action :authenticate_user!

  def index
    # Obtener casos únicos marcados para enseñanza
    @teaching_cases = Task.teaching_library_for_user(current_user)

    # Agrupar por modalidad para mejor organización
    @cases_by_modality = @teaching_cases.group_by(&:modality)

    # Estadísticas
    @total_teaching_cases = @teaching_cases.count
    @modalities_count = @cases_by_modality.keys.count
  end

  def show
    @case = Case.find(params[:id])
    @teaching_task = @case.tasks.marked_for_teaching.first

    # Verificar que el caso pertenece al usuario actual
    unless @case.user == current_user
      redirect_to teaching_cases_path, alert: 'No tienes acceso a este caso'
      return
    end

    # Casos relacionados (misma modalidad y parte del cuerpo)
    @related_cases = Task.marked_for_teaching
                         .joins(:case)
                         .where(user: current_user)
                         .where(cases: {
                           modality: @case.modality,
                           body_part: @case.body_part
                         })
                         .where.not(case_id: @case.id)
                         .limit(5)
  end
end
