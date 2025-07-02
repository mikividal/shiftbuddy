# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# Métodos auxiliares para generar contenido realista
def generate_findings(case_obj)
  findings_map = {
    'CT' => {
      'Head/Brain' => 'Sin evidencia de hemorragia intracraneal aguda. Estructuras de línea media centradas.',
      'Chest' => 'Pulmones sin consolidaciones. Silueta cardíaca normal. Sin derrame pleural.',
      'Abdomen' => 'Órganos abdominales sin alteraciones. Sin líquido libre intraperitoneal.'
    },
    'MRI' => {
      'Head/Brain' => 'Secuencias FLAIR, T1 y T2 sin lesiones focales. Espacios de LCR normales.',
      'Spine' => 'Alineación vertebral conservada. Discos intervertebrales sin protrusiones significativas.'
    },
    'XR' => {
      'Chest' => 'Campos pulmonares claros. Silueta cardiovascular normal. Sin fracturas costales.'
    },
    'US' => {
      'Abdomen' => 'Ecogenicidad hepática homogénea. Vesícula biliar sin litiasis. Riñones de tamaño normal.'
    }
  }

  findings_map.dig(case_obj.modality, case_obj.body_part) || 'Estudio dentro de límites normales.'
end

def generate_impression(case_obj)
  if case_obj.priority == 'stat'
    'Estudio normal. Sin hallazgos agudos.'
  else
    'Sin alteraciones significativas en el estudio actual.'
  end
end

def generate_teaching_note(case_obj)
  notes = [
    "Excelente ejemplo de anatomía normal en #{case_obj.modality}",
    "Buen caso para enseñar técnica de #{case_obj.modality}",
    "Interesante correlación clínico-radiológica",
    "Caso típico de #{case_obj.body_part} en paciente joven",
    "Bueno para demostrar protocolo de #{case_obj.priority}"
  ]

  notes.sample
end

def generate_qa_note(case_obj)
  notes = [
    "Revisar técnica de adquisición",
    "Verificar protocolos utilizados",
    "Correlacionar con hallazgos clínicos",
    "Revisar calidad de imagen",
    "Confirmar interpretación con supervisor"
  ]

  notes.sample
end

puts "🚀 Creando datos de prueba para ShiftBuddy..."

# Limpiar datos existentes completamente en el orden correcto
puts "🧹 Limpiando base de datos..."
Task.destroy_all
Case.destroy_all

# Primero quitar las referencias attending_id antes de borrar usuarios
User.update_all(attending_id: nil)
User.destroy_all

puts "🏥 Creando usuarios..."

# Crear un supervisor (attending)
attending = User.create!(
  email: 'supervisor@hospital.com',
  password: 'password123',
  first_name: 'Dra. María',
  last_name: 'González',
  current_rotation: 'chest',
  pager_number: '1234'
)

# Crear residentes
resident1 = User.create!(
  email: 'residente1@hospital.com',
  password: 'password123',
  first_name: 'Carlos',
  last_name: 'Rodríguez',
  year_of_training: 3,
  current_rotation: 'chest',
  pager_number: '5678',
  preferred_modalities: 'CT, MRI',
  attending: attending
)

resident2 = User.create!(
  email: 'residente2@hospital.com',
  password: 'password123',
  first_name: 'Ana',
  last_name: 'López',
  year_of_training: 2,
  current_rotation: 'abdomen',
  pager_number: '9012',
  preferred_modalities: 'US, CT',
  attending: attending
)

puts "📋 Creando casos de radiología..."

# Casos STAT (urgentes)
stat_cases = [
  {
    accession_number: 'STAT001',
    patient_name: 'Urgente, Pedro',
    patient_mrn: 'MRN001',
    modality: 'CT',
    body_part: 'Head/Brain',
    priority: 'stat',
    clinical_history: 'ACV agudo, evaluar hemorragia',
    user: resident1,
    attending: attending,
    study_date: 30.minutes.ago
  },
  {
    accession_number: 'STAT002',
    patient_name: 'Crítico, Ana',
    patient_mrn: 'MRN002',
    modality: 'CT',
    body_part: 'Chest',
    priority: 'stat',
    clinical_history: 'Trauma torácico, descartar hemotórax',
    user: resident2,
    attending: attending,
    study_date: 45.minutes.ago
  }
]

# Casos URGENT
urgent_cases = [
  {
    accession_number: 'URG001',
    patient_name: 'García, Luis',
    patient_mrn: 'MRN003',
    modality: 'MRI',
    body_part: 'Spine',
    priority: 'urgent',
    clinical_history: 'Dolor lumbar severo, radiculopatía',
    user: resident1,
    attending: attending,
    study_date: 2.hours.ago
  },
  {
    accession_number: 'URG002',
    patient_name: 'Martínez, Carmen',
    patient_mrn: 'MRN004',
    modality: 'US',
    body_part: 'Abdomen',
    priority: 'urgent',
    clinical_history: 'Dolor abdominal agudo, descartar apendicitis',
    user: resident2,
    attending: attending,
    study_date: 3.hours.ago
  }
]

# Casos ROUTINE
routine_cases = [
  {
    accession_number: 'ROU001',
    patient_name: 'López, María',
    patient_mrn: 'MRN005',
    modality: 'XR',
    body_part: 'Chest',
    priority: 'routine',
    clinical_history: 'Control post-operatorio',
    user: resident1,
    attending: attending,
    study_date: 6.hours.ago
  },
  {
    accession_number: 'ROU002',
    patient_name: 'Sánchez, David',
    patient_mrn: 'MRN006',
    modality: 'CT',
    body_part: 'Abdomen',
    priority: 'routine',
    clinical_history: 'Seguimiento oncológico',
    user: resident2,
    attending: attending,
    study_date: 1.day.ago
  },
  {
    accession_number: 'ROU003',
    patient_name: 'Fernández, Elena',
    patient_mrn: 'MRN007',
    modality: 'MRI',
    body_part: 'Head/Brain',
    priority: 'routine',
    clinical_history: 'Cefalea crónica, descartar lesiones',
    user: resident1,
    attending: attending,
    study_date: 8.hours.ago
  }
]

# Crear todos los casos
all_cases = stat_cases + urgent_cases + routine_cases
created_cases = []

all_cases.each do |case_data|
  created_case = Case.create!(case_data)
  created_cases << created_case
  puts "  ✅ Caso creado: #{created_case.display_name} (#{created_case.priority.upcase})"
end

puts "📝 Creando tareas..."

# Crear tareas para cada caso
created_cases.each_with_index do |case_obj, index|

  # Determinar el estado de la tarea basado en la antigüedad del caso
  case_age_hours = (Time.current - case_obj.created_at) / 1.hour

  if case_age_hours > 4
    # Casos viejos: completados
    task_status = 'completed'
    case_status = 'reported'
  elsif case_age_hours > 1
    # Casos medianos: en progreso
    task_status = 'in_progress'
    case_status = 'in_progress'
  else
    # Casos nuevos: pendientes
    task_status = 'pending'
    case_status = 'pending'
  end

  # Actualizar estado del caso
  case_obj.update!(study_status: case_status)

  # Crear tarea de interpretación
  interpretation_task = Task.create!(
    title: "Interpretar #{case_obj.modality} #{case_obj.body_part}",
    description: "Evaluación radiológica de: #{case_obj.clinical_history}",
    priority: case_obj.priority,
    task_type: 'interpretation',
    status: task_status,
    user: case_obj.user,
    case: case_obj,
    due_date: case_obj.priority == 'stat' ? 1.hour.from_now :
              case_obj.priority == 'urgent' ? 4.hours.from_now : 24.hours.from_now,
    estimated_time: case_obj.modality == 'CT' ? 30 :
                    case_obj.modality == 'MRI' ? 45 : 15
  )

  # Para tareas completadas, agregar tiempo real y hallazgos
  if interpretation_task.completed?
    interpretation_task.update!(
      actual_time: interpretation_task.estimated_time + rand(-5..10),
      findings: "Estudio de #{case_obj.modality} #{case_obj.body_part}. #{generate_findings(case_obj)}",
      impression: generate_impression(case_obj)
    )
  end

  # Crear tarea de reporte si la interpretación está completada
  if interpretation_task.completed?
    Task.create!(
      title: "Dictar reporte #{case_obj.modality} #{case_obj.body_part}",
      description: "Dictar reporte formal",
      priority: case_obj.priority,
      task_type: 'reporting',
      status: ['completed', 'pending'].sample,
      user: case_obj.user,
      case: case_obj,
      due_date: 2.hours.from_now,
      estimated_time: 10,
      actual_time: rand(5..15)
    )
  end

  puts "  ✅ Tareas creadas para: #{case_obj.display_name}"
end

puts "🎓 Marcando casos especiales..."

# Marcar algunos casos para enseñanza
teaching_cases = created_cases.sample(3)
teaching_cases.each do |case_obj|
  case_obj.tasks.first.mark_for_teaching!(
    generate_teaching_note(case_obj)
  )
  puts "  📚 Caso marcado para enseñanza: #{case_obj.display_name}"
end

# Marcar algunos casos para QA
qa_cases = created_cases.sample(2)
qa_cases.each do |case_obj|
  case_obj.tasks.first.mark_for_qa!(
    generate_qa_note(case_obj)
  )
  puts "  🔍 Caso marcado para QA: #{case_obj.display_name}"
end

puts "💉 Creando procedimientos..."

# Crear casos ficticios para los procedimientos
procedure_cases = [
  {
    accession_number: 'PROC001',
    patient_name: 'Procedimiento, Paciente1',
    patient_mrn: 'PROC_MRN001',
    modality: 'US',
    body_part: 'Abdomen',
    priority: 'urgent',
    clinical_history: 'Lesión focal hepática para biopsia',
    user: resident1,
    attending: attending,
    study_date: 1.day.from_now
  },
  {
    accession_number: 'PROC002',
    patient_name: 'Procedimiento, Paciente2',
    patient_mrn: 'PROC_MRN002',
    modality: 'US',
    body_part: 'Abdomen',
    priority: 'routine',
    clinical_history: 'Ascitis para paracentesis',
    user: resident2,
    attending: attending,
    study_date: 2.days.from_now
  },
  {
    accession_number: 'PROC003',
    patient_name: 'Procedimiento, Paciente3',
    patient_mrn: 'PROC_MRN003',
    modality: 'Angio',
    body_part: 'Head/Brain',
    priority: 'urgent',
    clinical_history: 'Evaluación vascular cerebral',
    user: resident1,
    attending: attending,
    study_date: 4.hours.from_now
  }
]

# Crear los casos para procedimientos
procedure_case_objects = []
procedure_cases.each do |case_data|
  proc_case = Case.create!(case_data)
  procedure_case_objects << proc_case
  puts "  ✅ Caso para procedimiento creado: #{proc_case.display_name}"
end

# Crear los procedimientos asociados a estos casos
procedures_data = [
  {
    title: "Biopsia hepática guiada por US",
    description: "Biopsia de lesión focal hepática en segmento VI",
    priority: 'urgent',
    task_type: 'procedure',
    status: 'pending',
    user: resident1,
    case: procedure_case_objects[0],
    due_date: 1.day.from_now,
    estimated_time: 60
  },
  {
    title: "Paracentesis diagnóstica",
    description: "Evacuación de líquido ascítico para análisis",
    priority: 'routine',
    task_type: 'procedure',
    status: 'pending',
    user: resident2,
    case: procedure_case_objects[1],
    due_date: 2.days.from_now,
    estimated_time: 45
  },
  {
    title: "Arteriografía cerebral",
    description: "Evaluación vascular cerebral",
    priority: 'urgent',
    task_type: 'procedure',
    status: 'pending',
    user: resident1,
    case: procedure_case_objects[2],
    due_date: 4.hours.from_now,
    estimated_time: 90
  }
]

procedures_data.each do |proc_data|
  procedure = Task.create!(proc_data)
  puts "  ✅ Procedimiento creado: #{procedure.title}"
end

puts "\n🎉 ¡Datos de prueba creados exitosamente!"
puts "\n👥 Usuarios creados:"
puts "  Supervisor: supervisor@hospital.com (password: password123)"
puts "  Residente 1: residente1@hospital.com (password: password123)"
puts "  Residente 2: residente2@hospital.com (password: password123)"
puts "  Usuario existente: test@test.com (password: password123)" if User.find_by(email: 'test@test.com')

puts "\n📊 Estadísticas finales:"
puts "  #{User.count} usuarios"
puts "  #{Case.count} casos (#{Case.stat.count} STAT, #{Case.urgent.count} urgentes, #{Case.routine.count} rutina)"
puts "  #{Task.count} tareas"
puts "  #{Task.marked_for_teaching.count} casos marcados para enseñanza"
puts "  #{Task.marked_for_qa.count} casos marcados para QA"
puts "  #{Task.procedure.count} procedimientos programados"
