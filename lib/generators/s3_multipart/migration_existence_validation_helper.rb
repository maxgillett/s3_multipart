module MigrationExistenceValidationHelper
  attr_reader :migration_name

  def prompt_if_exists(for_file:, to_execute:)
    @migration_name = for_file

    if matching_migrations.length > 0
      say_status('conflict', matching_migrations.join(', '), :red)
      to_execute.call if agree_to_create_file
    else
      to_execute.call
    end
  end

  private

  def agree_to_create_file
    yes? "#{matching_migrations.length > 1 ? 'Migrations exist' : 'Migration exists'}, "\
      "creating a new migration may cause a migration error. Do you want to create the file? (y/n)"
  end

  def migration_file_path
    "db/migrate/*_#{migration_name}.rb"
  end

  def matching_migrations
    Dir[migration_file_path]
  end
end
