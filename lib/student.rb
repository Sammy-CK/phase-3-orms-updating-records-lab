require_relative "../config/environment.rb"
class Student
  attr_accessor :name, :grade, :id

  def initialize (name, grade, id = nil)
    @name = name
    @grade = grade
    @id = id
  end
 
  def self.create_table
    query = <<-SQL
        CREATE TABLE IF NOT EXISTS students (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT,
          grade TEXT
        )
    SQL
    DB[:conn].query(query)
  end

  def self.drop_table
    query = <<-SQL
      DROP TABLE students
    SQL
    DB[:conn].query(query)
  end


  def save
    if self.id
      query = <<-SQL
        UPDATE students SET name = ?, grade = ? WHERE id = ?
      SQL
      DB[:conn].execute(query, self.name, self.grade, self.id)
    else
    query = <<-SQL
      INSERT INTO students (name, grade) VALUES (?, ?)
    SQL

    DB[:conn].execute(query, self.name, self.grade)
    self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
    end
  end

  def self.create(name, grade)
    new_song = self.new(name, grade)
    new_song.save
  end

  def self.new_from_db(row)
    new_student = self.new(row[1], row[2], row[0])
  
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT *
      FROM students
      WHERE name = ?
      LIMIT 1
    SQL

    DB[:conn].execute(sql,name).map do |row|
      self.new_from_db(row)
    end.first
  end

  def update
    query = <<-SQL
    UPDATE students SET name = ?, grade = ? WHERE id = ?
    SQL

    DB[:conn].execute(query, self.name, self.grade, self.id)
  end


end
